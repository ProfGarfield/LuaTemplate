// run the script makeObjectJS.lua once you have finalized object.lua
// in order to generate an object.js file fitting your scenario

const unitList = [
    {name:"Sample Unit 0",id:0,code:"object.uSampleUnit0"},
    {name:"Sample Unit 1",id:1,code:"object.uSampleUnit1"},
    {name:"Sample Unit 2",id:2,code:"object.uSampleUnit2"},
]

const tribeList = [
    {name:"Barbarians",id:0,code:"object.pBarbarians"},
    {name:"Sample Tribe 1",id:1,code:"object.pSampleTribe1"},
    {name:"Sample Tribe 2",id:2,code:"object.pSampleTribe2"},
    {name:"Sample Tribe 3",id:3,code:"object.pSampleTribe3"},
    {name:"Sample Tribe 4",id:4,code:"object.pSampleTribe4"},
    {name:"Sample Tribe 5",id:5,code:"object.pSampleTribe5"},
    {name:"Sample Tribe 6",id:6,code:"object.pSampleTribe6"},
    {name:"Sample Tribe 7",id:7,code:"object.pSampleTribe7"},
]

const improvementList = [
    {name:"Nothing",id:0,code:"object.iNothing"},
    {name:"Sample Improvement 1",id:1,code:"object.iSampleImprovement1"},
    {name:"Sample Improvement 2",id:2,code:"object.iSampleImprovement2"},
    {name:"Sample Improvement 3",id:3,code:"object.iSampleImprovement3"},
]

const wonderList = [
    {name:"Sample Wonder 0",id:0,code:"object.wSampleWonder0"},
    {name:"Sample Wonder 1",id:1,code:"object.wSampleWonder1"},
    {name:"Sample Wonder 2",id:2,code:"object.wSampleWonder2"},
    {name:"Sample Wonder 3",id:3,code:"object.wSampleWonder3"},
]

const cityLocationList = [
    {name:"Sample City 0",id:0,tribeId:2,code:"object.lSampleCity0",xyz:[0,2,0]},
    {name:"Sample City 1",id:1,tribeId:1,code:"object.lSampleCity1",xyz:[11,13,0]},
    {name:"Sample City 2",id:2,tribeId:1,code:"object.lSampleCity2",xyz:[22,44,1]},
    {name:"Sample City 3",id:3,tribeId:0,code:"object.lSampleCity3",xyz:[21,63,0]},
]

const advancesList = [
    {name:"Sample Tech 0",id:0,code:"object.aSampleTech0"},
    {name:"Sample Tech 1",id:1,code:"object.aSampleTech1"},
    {name:"Sample Tech 2",id:2,code:"object.aSampleTech2"},
    {name:"Sample Tech 3",id:3,code:"object.aSampleTech3"},
    {name:"Sample Tech 4",id:4,code:"object.aSampleTech4"},
]

// id exists only for consistency with other objects
const flagsList = [
    {name:'Flag: "SampleFlag1"', id:1,code:"SampleFlag1"},
    {name:'Flag: "SampleFlag4"', id:2,code:"SampleFlag4"},
    {name:'Flag: "SampleFlag3"', id:3,code:"SampleFlag3"},
    {name:'Flag: "SampleFlag2"', id:4,code:"SampleFlag2"},
]
// id exists only for consistency with other objects
const countersList = [
    {name:'Counter: "SampleCounter1"', id:1,code:"SampleCounter1"},
    {name:'Counter: "SampleCounter4"', id:2,code:"SampleCounter4"},
    {name:'Counter: "SampleCounter3"', id:3,code:"SampleCounter3"},
    {name:'Counter: "SampleCounter2"', id:4,code:"SampleCounter2"},
]

const fullList = {}
const fullArray = [...unitList,...tribeList,...improvementList,...wonderList,...cityLocationList,...advancesList,...flagsList,...countersList]

fullArray.map( value => {
            fullList[value.code] = value;
    });

const testObject = true;

