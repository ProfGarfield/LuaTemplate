
const settingGeneratorForm = document.getElementById('setting-generator');
const listGeneratorDiv = document.getElementById('list-generator');
const settingOutputCode = document.getElementById('setting-output-code');
const chooseItemSelect = document.getElementById('choose-item');
const generateCodeButton = document.getElementById('generate-code-button');

const listsCatalogueArray = JSON.parse(localStorage.getItem("Saved Lists") || "[]");

window.onbeforeunload = function(event) {
    localStorage.setItem("ListsCatalogue",JSON.stringify(listsCatalogueArray))
};

makeItemSelection(chooseItemSelect,[]);


function updateListCatalogue() {

}


function makeForbiddenTribesBoxes() {
    const forbiddenTribesDiv = document.getElementById('forbidden-tribes');
    tribeList.map(tribeObject => {
        const label = document.createElement('label');
        label.innerHTML =
            `<div><input type="checkbox" name="${tribeObject.code}">
            <span>${tribeObject.name}</span></div>`
        forbiddenTribesDiv.appendChild(label);
    });

}

function computeForbiddenTribesCode() {
    let makeOutput=false
    let outString = 'forbiddenTribes = {'
    tribeList.map( object => {
        const code = object.code
        const ckbx = document.querySelector(`input[name='${code}']`)
        if (ckbx.checked) {
            makeOutput=true;
            outString += `[${code}.id]=true, `
        }
    });
    outString +="}, "
    if (makeOutput) {
        return outString;
    } else {
        return "";
    }
}

function makeForbiddenMapsBoxes() {
    const forbiddenMapsDiv = document.getElementById('forbidden-maps');
    const mapList = [0,1,2,3];
    mapList.map(mapId => {
        const label = document.createElement('label');
        label.innerHTML =
            `<div><input type="checkbox" name="map${mapId}">
            <span>Map ${mapId}</span></div>`
        forbiddenMapsDiv.appendChild(label);
    });
}

function computeForbiddenMapsCode() {
    let makeOutput=false
    let outString = 'forbiddenMaps = {'
    const mapList = [0,1,2,3]
    mapList.map( mapId => {
        const ckbx = document.querySelector(`input[name='map${mapId}']`)
        if (ckbx.checked) {
            makeOutput=true;
            outString += `[${mapId}]=true, `
        }
    });
    outString +="}, "
    if (makeOutput) {
        return outString;
    } else {
        return "";
    }
}


function updateHeadings() {
    const itemName = fullList[chooseItemSelect.value].name;
    document.getElementById('forbidden-tribes-legend').textContent =
        `${itemName} can't be built by selected tribes.`;
    document.getElementById('forbidden-maps-legend').textContent = 
        `${itemName} can't be built on selected maps.`
    document.getElementById('location-legend').textContent =
        `${itemName} can only be built in these cities`
    document.getElementById('forbidden-location-legend').textContent = 
        `${itemName} can't be built in any of these cities.`
    document.getElementById('all-improvements-legend').textContent=
        `${itemName} can only be built in cities with all of these improvements.`
    const numberOfImprovements = parseInt(document.getElementById('number-of-improvements').value);
    document.getElementById('some-improvements-legend').textContent=
        `${itemName} can only be built in cities with at least ${numberOfImprovements || 0} of these improvements.`
    document.getElementById('forbidden-improvements-legend').textContent=
        `${itemName} can't be built in cities with any of these improvements.`
    document.getElementById('all-wonders-legend').textContent=
        `${itemName} can only be built by tribes controlling all of these wonders.`
    const numberOfwonders = parseInt(document.getElementById('number-of-wonders').value);
    document.getElementById('some-wonders-legend').textContent=
        `${itemName} can only be built by tribes controlling at least ${numberOfwonders || 0} of these wonders.`
    document.getElementById('forbidden-improvements-legend').textContent=
        `${itemName} can't be built in cities with any of these improvements.`
    document.getElementById('all-techs-legend').textContent=
        `${itemName} can only be built by tribes with all of these technologies.`
    const numberOfTechs = parseInt(document.getElementById('number-of-techs').value);
    document.getElementById('some-techs-legend').textContent=
        `${itemName} can only be built by tribes with at least ${numberOfTechs || 0} of these technologies.`
    document.getElementById('forbidden-techs-legend').textContent =
        `${itemName} can't be built by tribes posessing any of these technologies.`
    document.getElementById('all-flags-match-legend').textContent=
        `${itemName} can only be built when all of these flags match the stated values.`
    const numberOfFlags = parseInt(document.getElementById('number-of-flags').value);
    document.getElementById('some-flags-match-legend').textContent=
        `${itemName} can only be built when at least ${numberOfFlags || 0} of these flags match the stated values.`
    const minimumPopulation = parseInt(document.getElementById('minimum-population').value)
    const maximumPopulation = parseInt(document.getElementById('maximum-population').value)
    const cityPopulationLegend = document.getElementById('city-population-legend')
    if (minimumPopulation && maximumPopulation) {
        cityPopulationLegend.textContent = 
            `${itemName} can only be built in cities with population of at least ${minimumPopulation} and at most ${maximumPopulation}.`
    } else if (minimumPopulation) {
        cityPopulationLegend.textContent = 
            `${itemName} can only be built in cities with population of at least ${minimumPopulation}.`
    } else if (maximumPopulation) {
        cityPopulationLegend.textContent = 
            `${itemName} can only be built in cities with population not exceeding ${maximumPopulation}.`
    } else {
        cityPopulationLegend.textContent = 
            `Change the values below to restrict the size of cities in which ${itemName} can be built.`
    }
    const firstTurn = parseInt(document.getElementById('first-turn').value)
    const lastTurn= parseInt(document.getElementById('last-turn').value)
    const turnRestrictionLegend = document.getElementById('turn-restriction-legend')
    if (firstTurn && lastTurn) {
        turnRestrictionLegend.textContent = 
            `${itemName} can't be built before turn ${firstTurn} or after ${lastTurn}.`
    } else if (firstTurn) {
        turnRestrictionLegend.textContent = 
            `${itemName} can't be built before turn ${firstTurn}.`
    } else if (lastTurn) {
        turnRestrictionLegend.textContent = 
            `${itemName} can't be built after turn ${lastTurn}.`
    } else {
        turnRestrictionLegend.textContent = 
            `Change the values below to restrict the turns when ${itemName} can be built.`
    }
    document.getElementById('forbidden-alternate-production-legend').textContent = 
        `${itemName} can not be built in cities which are allowed to build any of these items.`
    const numberOfAlternateProduction = parseInt(document.getElementById('number-of-alternate-production').value)
    document.getElementById('require-some-as-alternate-production-legend').textContent =
        `${itemName} can only be built in cities which can also build at least ${numberOfAlternateProduction} of these items.`


    const nameSpanList = document.querySelectorAll('.item-name');
    for (let i = 0; i < nameSpanList.length; i++) {
        nameSpanList[i].textContent = itemName;
    }


}

function generateOutput() {
    const itemValue = chooseItemSelect.value;
    let outString = ""
    if (itemValue.charAt(7) === 'u') {
        outString = `unitTypeBuild[${itemValue}.id] = {`
    } else if (itemValue.charAt(7) === 'i') {
        outString = `improvementBuild[${itemValue}.id] = {`
    } else if (itemValue.charAt(7) === 'w') {
        outString = `wonderBuild[${itemValue}.id] = {`
    }
    outString += computeForbiddenTribesCode();
    outString += computeForbiddenMapsCode();

    outString += '}'
    settingOutputCode.textContent = outString;
}
// Event Listeners

chooseItemSelect.addEventListener('change', e => {
    updateHeadings();
});

const numberBoxes = document.querySelectorAll('.number-input')
for (let i = 0; i < numberBoxes.length; i++){
    const box = numberBoxes[i];
    box.addEventListener('input', e =>{
        if (box.value.match(/[^\d]/)) {
            box.value = box.value.replace(/[^\d]/g,"");
        }
        updateHeadings()
    });
}


//generateCodeButton.addEventListener('click',generateOutput);
settingGeneratorForm.addEventListener("submit", (e) => {
    e.preventDefault();
    generateOutput();
});

function createOptionsFromArray(parentNode,array,excludedCodeArray) {
    array.map( object => {
        if (!excludedCodeArray.includes(object.code)) {
            const nextOption = document.createElement('option');
            nextOption.value = object.code;
            nextOption.textContent = `${object.name} (id: ${object.id})`
            parentNode.appendChild(nextOption);
        }
    });
}



function makeItemSelection(selectNode,excluded) {
    const unitOptGp = document.createElement('optgroup')
    unitOptGp.label = "Units";
    selectNode.appendChild(unitOptGp);
    const improvementOptGp = document.createElement('optgroup')
    improvementOptGp.label = "Improvements";
    selectNode.appendChild(improvementOptGp);
    const wonderOptGp = document.createElement('optgroup')
    wonderOptGp.label = "Wonders";
    selectNode.appendChild(wonderOptGp);
    createOptionsFromArray(unitOptGp,unitList,excluded)
    createOptionsFromArray(improvementOptGp,improvementList,excluded)
    createOptionsFromArray(wonderOptGp,wonderList,excluded)


}

function removeArrayValue(array,value) {
    const valueIndex = array.indexOf(value);
    if (valueIndex > -1) {
        array.splice(valueIndex,1);
    }
}


function makeListEntry(parentNode,listStorageArray,codeName,selectArray){
    const li = document.createElement('li');
    const removeButton = document.createElement('button');
    removeButton.textContent = "remove"
    listStorageArray.push(codeName);
    const nameSpan = document.createElement('span');
    nameSpan.textContent = fullList[codeName].name;
    li.appendChild(nameSpan);
    li.appendChild(removeButton);
    removeButton.addEventListener('click', e => {
        removeArrayValue(listStorageArray,codeName);
        unhideSelection(selectArray,codeName);
        li.remove();
    });
    if (parentNode.children[0]) {
        parentNode.insertBefore(li,parentNode.children[0]);
    } else {
        parentNode.appendChild(li);
    }
}

function hideSelection(selectArray,code) {
    for (let i = 0; i < selectArray.length; i++) {
        const options = selectArray[i].children;
        for (let j = 0; j < options.length; j++) {
            if (options[j].value === code) {
                options[j].hidden = true;
            }
        }
    }
}

function unhideSelection(selectArray,code) {
    for (let i = 0; i < selectArray.length; i++) {
        const options = selectArray[i].children;
        for (let j = 0; j < options.length; j++) {
            if (options[j].value === code) {
                options[j].hidden = false;
            }
        }
    }
}


let listNumberCount = 0;

function makeListCreatorForm(optionsArrays,optionsArraysTitles,listStorageArray) {
    listNumberCount ++;
    const makeListForm = document.createElement('form');
    const listNameDiv = document.createElement('div');
    const listNameLabel = document.createElement('label');
    listNameLabel.htmlFor = `list-name-${listNumberCount}`;
    listNameLabel.textContent = "Select a variable name for this list:";
    listNameDiv.appendChild(listNameLabel);
    const listNameInput = document.createElement('input');
    listNameInput.type = "text";
    listNameInput.id = `list-name-${listNumberCount}`;
    listNameInput.className="variable-name-input";
    listNameDiv.appendChild(listNameInput);
    makeListForm.appendChild(listNameDiv);
    const codeOutputDiv = document.createElement('div');
    const generateListButton = document.createElement('button');
    generateListButton.type = "submit";
    generateListButton.textContent = "Generate List Code"
    codeOutputDiv.appendChild(generateListButton);
    const saveListButton = document.createElement('button');
    saveListButton.textContent = "Add to List Catalogue"

    codeOutputDiv.appendChild(saveListButton);
    codeOutputDiv.appendChild(document.createElement('br'))
    codeOutputDiv.appendChild(document.createElement('br'))
    const codeOutputElement = document.createElement('code');
    codeOutputDiv.appendChild(codeOutputElement);
    makeListForm.appendChild(codeOutputDiv);
    makeListForm.appendChild(document.createElement('br'))
    const selectElementList = []
    const emptyChoiceList = []
    for (let i = 0; i < optionsArrays.length; i++) {
        const selectElement = document.createElement('select')
        const emptyChoice = document.createElement('option')
        emptyChoice.textContent = optionsArraysTitles[i];
        selectElementList.push(selectElement);
        emptyChoiceList.push(emptyChoice);
        selectElement.appendChild(emptyChoice);
        createOptionsFromArray(selectElement,optionsArrays[i],listStorageArray);
        makeListForm.appendChild(selectElement);
    }
    makeListForm.appendChild(document.createElement('br'))
    const addButton = document.createElement('button');
    addButton.textContent = "Add to list";
    addButton.disabled = true;
    makeListForm.appendChild(addButton);
    const choiceSpan = document.createElement('span');
    makeListForm.appendChild(choiceSpan);
    function makeChangeEvent(index) {
        const changedNode = selectElementList[index];
        const chEvnFn = (e) => {
            for(let i = 0; i < emptyChoiceList.length; i++) {
                if (i !== index) {
                    emptyChoiceList[i].selected = true;
                }
            }
            if (changedNode.value) {
                choiceSpan.textContent = fullList[changedNode.value].name;
                choiceSpan.value = changedNode.value;
                addButton.disabled = false;
            } else {
                choiceSpan.textContent = ""
                addButton.disabled = true;
            }
        }
        return chEvnFn;
    }
    for (let i = 0; i < selectElementList.length; i++) {
        selectElementList[i].addEventListener('change',makeChangeEvent(i));
    }
    const entryList = document.createElement('ul');
    makeListForm.appendChild(document.createElement('br'));
    makeListForm.appendChild(entryList);
    addButton.addEventListener('click',e => {
        makeListEntry(entryList,listStorageArray,choiceSpan.value,selectElementList);
        hideSelection(selectElementList,choiceSpan.value);
        for (let i = 0; i < emptyChoiceList.length; i++) {
            emptyChoiceList[i].selected = true;
            choiceSpan.value = "";
            choiceSpan.textContent = "";
            addButton.disabled = true;
        }
    });
    makeListForm.addEventListener('submit', e => {
        e.preventDefault();
        let codeString = "local ";
        codeString = codeString+listNameInput.value+" = {"
        for (let i = 0; i < listStorageArray.length; i++) {
            codeString = codeString+listStorageArray[i]+", ";
        }
        codeString = codeString +"}";
        codeOutputElement.textContent = codeString;
    });
    return makeListForm;
}
// an array of saved lists
// arguments are:
// {"code":variableName, listStorageArray:[codeOfItem],optionsArrays:[optionsArray], optionsArraysTitles:[string]}



// initialize Page
makeForbiddenTribesBoxes();
makeForbiddenMapsBoxes();
updateHeadings();
const sampleListValueArray = []
listGeneratorDiv.appendChild(makeListCreatorForm([unitList,improvementList,wonderList],["units","improvements","wonders"],sampleListValueArray))

