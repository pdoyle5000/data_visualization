package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"sort"
	"net/http"
	"os"
	"strings"
	"sync"
)

// Endpoints not accessable outside secure VPN
const all_builds_url = "https://gradle.is.idexx.com/build-export/v1/builds/since/0"
const detailsPt = "https://gradle.is.idexx.com/build-export/v1/build/"

type gradleBuild struct {
	BuildId       string `json:"buildId"`
	PluginVersion string `json:"pluginVersion"`
	GradleVersion string `json:"gradleVersion"`
	Timestamp     int64  `json:"timestamp"`
}

type singleBuild struct {
	Timestamp int64      `json:"timestamp"`
	Type      gradleType `json:"type,omitempty"`
	Data      gradleData `json:"data,omitempty"`
	File      gradleFile `json:"file,omitempty"`
}

type gradleType struct {
	MajorVersion int    `json:"majorVersion,omitempty"`
	MinorVersion int    `json:"minorVersion,omitempty"`
	EventType    string `json:"eventType,omitempty"`
}

type gradleData struct {
	Id              int64  `json:"id,omitempty"`
	RootProjectName string `json:"rootProjectName"`
	TargetType      string `json:"targetType,omitempty"`
	TargetPath      string `json:"targetPath,omitempty"`
	BuildPath       string `json:"buildPath,omitempty"`
	PluginClassName string `json:"pluginClassName,omitempty"`
	InferredVersion string `json:"inferredVersion,omitempty"`
	InferredId      string `json:"inferredId,omitempty"`
	CodeSourceType  string `json:"codeSourceType,omitempty"`
}

type gradleFile struct {
	Root string `json:"root,omitempty"`
	Path string `json:"path,omitempty"`
}

type fullGradleBuildData struct {
	Overview gradleBuild
	Details  []singleBuild
}

type flatData struct {
	BuildId       string `json:"buildId"`
	GradleVersion string `json:"gradleVersion"`
	PluginVersion string `json:"pluginVersion`
	BuildStart int64  `json:"buildStart"`
	BuildEnd   int64  `json:"buildEnd"`
	Project    string `json:"project"`
	PluginList []string `json:"plugins"`
}

type pluginList struct {
	Timestamp int64 `json:"timestamp"`
	Project string `json:"project"`
	Plugin string `json:"plugin"`
}

func generatePluginList(f []flatData) {
	var outputList []pluginList
	for _, build := range f {
		for _, plugin := range build.PluginList {
			outputList = append(outputList, pluginList{
				Timestamp: build.BuildStart,
				Project: build.Project,
				Plugin: plugin,
				})
		}
	}
	outputPluginList(outputList)
}


func generateCleanData(b []fullGradleBuildData) (f []flatData) {
	for _, build := range b {
		var thisData flatData
		thisData.BuildId = build.Overview.BuildId
		log.Println(thisData.BuildId)
		thisData.GradleVersion = build.Overview.GradleVersion
		thisData.PluginVersion = build.Overview.PluginVersion
		thisData.BuildStart = build.getStartingTimeStamp()
		thisData.BuildEnd = build.Overview.Timestamp
		thisData.Project = build.getRootProjectName()
		thisData.PluginList = build.getUsedPlugins()
		f = append(f, thisData)
	}
	return
}

func (b *fullGradleBuildData) getStartingTimeStamp() int64 {
	if len(b.Details) > 1 {
		return b.Details[1].Timestamp
	}
	return 0
}

func (b *fullGradleBuildData) getRootProjectName() string {
	for _, event := range b.Details {
		if event.Type.EventType == "ProjectStructure" {
			return event.Data.RootProjectName
		}
	}
	return ""
}

func (b *fullGradleBuildData) getUsedPlugins() []string {
	var pList []string
	for _, event := range b.Details {
		if event.Type.EventType == "PluginApplicationStarted" ||
			event.Type.EventType == "PluginApplied" {
			pList = append(pList, event.Data.PluginClassName)
		}
	}
	return removeDuplicates(pList)
}

func removeDuplicates(l []string) []string {
	var newList []string
	sort.Strings(l)
	for i := 1; i < len(l); i++ {
		if l[i] != l[i-1] {
			newList = append(newList, l[i])
		}
	}
	return newList
}

func getAllBuilds() []gradleBuild {
	resp, err := http.Get(all_builds_url)
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
	log.Println("HTTP RESPONSE:", resp.StatusCode)
	defer resp.Body.Close()
	reader := bufio.NewReader(resp.Body)
	return (createBuildsList(reader))
}

func createBuildsList(reader *bufio.Reader) (builds []gradleBuild) {
	for {
		line, err := reader.ReadBytes('\n')
		if err != nil {
			break
		}
		if bytes.HasPrefix(line, []byte("data:")) {
			builds = append(builds, unmarshalBuildData(line))
		}
	}
	log.Println("Build List Generated.")
	return
}

func unmarshalBuildData(line []byte) (build gradleBuild) {
	dataLine := strings.SplitN(string(line), " ", 2)
	jsonErr := json.Unmarshal([]byte(dataLine[1]), &build)
	if jsonErr != nil {
		log.Println(jsonErr)
	}
	return
}

func unmarshalDetailsData(line []byte) (build singleBuild) {
	dataLine := strings.SplitN(string(line), " ", 2)
	jsonErr := json.Unmarshal([]byte(dataLine[1]), &build)
	if jsonErr != nil {
		log.Println(jsonErr)
	}
	return
}

func LoadAllGradleData() (f []fullGradleBuildData) {
	log.Println("Obtaining High Level Gradle Build Info.")
	allBuilds := getAllBuilds()
	numBuilds := len(allBuilds)
	log.Println("Total Builds:", numBuilds)

	maxThreads := 10
	for listLoc := 54000; listLoc < numBuilds; listLoc += maxThreads {
		log.Println("On Location:", listLoc)
		threadsToStart := min(maxThreads, numBuilds-listLoc)
		var wg sync.WaitGroup
		wg.Add(threadsToStart)

		for i := listLoc; i < listLoc+threadsToStart; i++ {
			go func(index int) {
				thisBuild := fullGradleBuildData{
					Overview: allBuilds[index],
					Details:  loadDetails(allBuilds[index].BuildId)}
				f = append(f, thisBuild)
				wg.Done()
			}(i)
		}
		wg.Wait()
	}
	log.Println("Complete.")
	return
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func loadDetails(buildId string) []singleBuild {
	resp, err := http.Get(detailsPt + buildId + "/events")
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
	defer resp.Body.Close()
	reader := bufio.NewReader(resp.Body)
	return (createDetailsList(reader))
}

func createDetailsList(reader *bufio.Reader) (s []singleBuild) {
	for {
		line, err := reader.ReadBytes('\n')
		if err != nil {
			break
		}
		if bytes.HasPrefix(line, []byte("data:")) {
			s = append(s, unmarshalDetailsData(line))
		}
	}
	return
}

func outputToFile(data []fullGradleBuildData) {
	jsonStr, toStrErr := json.Marshal(data)
	if toStrErr != nil {
		log.Println(toStrErr)
	}

	outputErr := ioutil.WriteFile("gradle_full_output.json", jsonStr, 0644)

	if outputErr != nil {
		log.Println(outputErr)
	}
	log.Println("Successful file output")
}

func outputToFlatFile(data []flatData) {
	jsonStr, toStrErr := json.Marshal(data)
	if toStrErr != nil {
		log.Println(toStrErr)
	}

	outputErr := ioutil.WriteFile("build_data.json", jsonStr, 0644)

	if outputErr != nil {
		log.Println(outputErr)
	}
	log.Println("Successful flat-file output")
}

func outputPluginList(data []pluginList) {
	jsonStr, toStrErr := json.Marshal(data)
	if toStrErr != nil {
		log.Println(toStrErr)
	}

	outputErr := ioutil.WriteFile("plugin_data.json", jsonStr, 0644)

	if outputErr != nil {
		log.Println(outputErr)
	}
	log.Println("Successful plugin-file output")
}

func importGradleData() (f []fullGradleBuildData) {
	raw, err := ioutil.ReadFile("gradle_full_output.json")
    if err != nil {
        log.Println(err)
        os.Exit(1)
    }
    json.Unmarshal(raw, &f)
    return
}


func main() {
	d := LoadAllGradleData()
	//d := importGradleData() // For importing pre-loaded query
	//outputToFile(d) // for saving a pre-loaded query
	final := generateCleanData(d)
	outputToFlatFile(final)
	generatePluginList(final)
}
