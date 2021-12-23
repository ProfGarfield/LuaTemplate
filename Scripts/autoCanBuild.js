
// Search For Tribe Totals
const settingGeneratorForm = document.getElementById('setting-generator');
const listGeneratorDiv = document.getElementById('list-generator');
const settingOutputCode = document.getElementById('setting-output-code');
const chooseItemSelect = document.getElementById('choose-item');
const generateCodeButton = document.getElementById('generate-code-button');
const listCatalogueDiv = document.getElementById('list-catalogue');
const listCatalogueList = document.getElementById('list-catalogue-list');

const listsCatalogueArray = JSON.parse(localStorage.getItem("Saved Lists") || "[]");
// an array of saved lists
// arguments are:
// {"code":variableName, listStorageArray:[codeOfItem],optionsArrays:[optionsArray], optionsArraysTitles:[string], fixedID:number}
let listID = 0;
class ListObject {
    constructor(variableName) {
        this.code = variableName;
        this.listStorageArray = [];
        this.optionsArrays = [];
        this.optionsArraysTitles = [];
        this.editing = false;
        listID++;
        this.fixedID = listID;
    }
    // methods
    addOption(optionArray,optionTitle) {
        this.optionsArrays.push(optionArray);
        this.optionsArraysTitles.push(optionTitle);
    }
    addItem(codeOfItem) {
        this.listStorageArray.push(codeOfItem);
    }
}
function getListObjectFromFixedId(id) {
    id = parseInt(id);
    for (let i = 0; i < listsCatalogueArray.length; i++) {
        if (listsCatalogueArray[i].fixedID === id) {
            return listsCatalogueArray[i];
        }
    }
}

function addCityLists(listObject) {
    for (let i = 0; i < 8; i++) {
        const tribeName = getItemWithId(i,tribeList).name 
        if (tribeName) {
            const tribeCities = [];
            cityLocationList.forEach(cityObject => {
                if (cityObject.tribeId === i) {
                    tribeCities.push(cityObject);
                    }
                });
            listObject.addOption(tribeCities,`Cities (${tribeName})`)
        }
    }
}

function getItemWithId(id,listOfObjects) {
    for (let i = 0; i < listOfObjects.length; i++) {
        if (listOfObjects[i].id === id) {
            return listOfObjects[i];
        }
    }
    return {};
}

window.onbeforeunload = function(event) {
    localStorage.setItem("ListsCatalogue",JSON.stringify(listsCatalogueArray))
};

makeItemSelection(chooseItemSelect,[]);

function deleteArrayIndex(array,index) {
    array.splice(index,1);
};

function makeCatalogueEntry(listObject,arrayIndex) {
    const li = document.createElement('li');
    const nameEl = document.createElement('code');
    nameEl.textContent = listObject.code;
    li.appendChild(nameEl);
    const editListButton = document.createElement('button');
    const deleteListButton = document.createElement('button');
    const undoDeleteButton = document.createElement('button');
    const confirmDeleteButton = document.createElement('button');
    editListButton.textContent = "Edit";
    editListButton.addEventListener('click', e => {
        listGeneratorDiv.appendChild(makeListCreatorForm(listObject));
        editListButton.disabled = true;
        deleteListButton.disabled = true;
        listObject.editing = true;
        });
    editListButton.disabled = listObject.editing;
    li.appendChild(editListButton);
    li.appendChild(deleteListButton);
    deleteListButton.textContent = "Delete";
    deleteListButton.disabled = listObject.editing;
    deleteListButton.addEventListener('click', e => {
        deleteListButton.hidden = true;
        undoDeleteButton.hidden = false;
        editListButton.disabled = true;
        confirmDeleteButton.hidden = false;
    })
    li.appendChild(undoDeleteButton);
    undoDeleteButton.hidden = true;
    undoDeleteButton.textContent = "Stop Deletion"
    undoDeleteButton.addEventListener('click', e => {
        deleteListButton.hidden = false
        undoDeleteButton.hidden = true;
        confirmDeleteButton.hidden = true;
        editListButton.disabled = false;
    });
    li.appendChild(confirmDeleteButton);
    confirmDeleteButton.hidden = true;
    confirmDeleteButton.textContent = "Confirm Deletion"
    confirmDeleteButton.addEventListener('click', e => {
        deleteArrayIndex(listsCatalogueArray,arrayIndex);
        makeListCatalogueBox();
        updateAllListSelectors();
    });
    const codeElement = document.createElement('code');
    const showCode = document.createElement('button');
    const editCodeHelp = document.createElement('span');
    editCodeHelp.textContent = "Edit list name to show code."
    editCodeHelp.style.color = 'red';
    editCodeHelp.hidden = true;
    const showCodeBreak = document.createElement('br');
    showCodeBreak.hidden = true;
    li.appendChild(showCode);
    li.appendChild(editCodeHelp);
    li.appendChild(showCodeBreak);
    li.appendChild(codeElement);
    showCode.textContent = "Show Code"
    showCode.addEventListener('click', e => {
        showCodeBreak.hidden = false;
        codeElement.textContent = "\n"+generateListCode(listObject);
    });
    if (isInvalidVariableName(nameEl.textContent)) {
        nameEl.style.color = 'red';
        editCodeHelp.hidden = false;
        showCode.disabled = true;
    }
    return li;
}

function generateListConstructor(listObject) {
    let output = "{";
    const actualList = listObject.listStorageArray;
    for (let i = 0; i < actualList.length; i++) {
        output = output + actualList[i] +", ";
    }
    output = output+"}";
    return output;

}

function generateListCode(listObject) {
    return `local ${listObject.code} = `+ generateListConstructor(listObject)
}

function isInvalidVariableName(varName) {
    return !varName.match(/^[a-zA-Z_][a-zA-Z0-9_]*$/g)
}


function deleteAllChildren(element) {
    while(element.lastChild) {
        element.removeChild(element.lastChild);
    }
}
function makeCheckbox(name,text,optionsArray,optionsArrayTitle,checkboxList) {
    const label = document.createElement('label');
    const checkbox = document.createElement('input');
    checkbox.name = name;
    checkbox.type = "checkbox";
    label.appendChild(checkbox);
    const span = document.createElement('span');
    span.textContent = text;
    label.appendChild(span);
    checkboxList.push({'element':checkbox,'optionsArray':optionsArray,'optionsArrayTitle':optionsArrayTitle});
    return label;
}

function makeListCatalogueBox() {
    deleteAllChildren(listCatalogueList);
    for (let i = 0; i < listsCatalogueArray.length; i++) {
        listCatalogueList.appendChild(makeCatalogueEntry(listsCatalogueArray[i],i));
    }
    const li = document.createElement('li');
    const availableOptionsCheckboxes = document.createElement('div')
    const checkboxList = []
    availableOptionsCheckboxes.appendChild(makeCheckbox('unit-list',"Units",unitList,"Units",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('improvement-list',"Improvements",improvementList,"Improvements",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('wonder-list',"Wonders",wonderList,"Wonders",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('tribe-list',"Tribes",tribeList,"Tribes",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('advances-list',"Advances",advancesList,"Advances",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('cities',"Cities",cityLocationList,"Cities",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('flags',"Flags",flagsList,"Flags",checkboxList))
    availableOptionsCheckboxes.appendChild(makeCheckbox('counters',"Counters",countersList,"Counters",checkboxList))
    li.appendChild(availableOptionsCheckboxes);
    const listNamerLabel = document.createElement('label');
    listNumberCount++;
    listNamerLabel.htmlFor = `list-namer-${listNumberCount}`;
    listNamerLabel.textContent = "List variable name:";
    li.appendChild(listNamerLabel);
    const listNamer = document.createElement('input');
    listNamer.value="newList";
    li.appendChild(listNamer);
    const addNewListButton = document.createElement('button');
    addNewListButton.textContent = "Create New List";
    addNewListButton.addEventListener('click', e => {
        const listObject = new ListObject(listNamer.value);
        for (let i = 0; i < checkboxList.length; i++) {
            if (checkboxList[i].element.checked && checkboxList[i].element.name === "cities") {
                addCityLists(listObject);
            } else if (checkboxList[i].element.checked) {
                listObject.addOption(checkboxList[i].optionsArray,checkboxList[i].optionsArrayTitle);
            }
        }
        listsCatalogueArray.push(listObject);
        makeListCatalogueBox();
        updateAllListSelectors();
    });
    li.appendChild(addNewListButton);
    listCatalogueList.appendChild(li);
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
    const maxNumberTribeRadioLimited = document.getElementById('max-number-tribe-radio-limited')
    const maxNumberTribeLegend = document.getElementById('max-number-tribe-legend')
    if (maxNumberTribeRadioLimited.checked) {
        maxNumberTribeLegend.textContent = `Each tribe can only own a limited number of ${itemName}.`
        document.getElementById("max-number-tribe-settings").style.display = '';
    } else {
        maxNumberTribeLegend.textContent = `Tribes have no limit on their ownership of ${itemName}.`
        document.getElementById("max-number-tribe-settings").style.display = 'none';
    }

    const maxNumberGlobalRadioLimited = document.getElementById('max-number-global-radio-limited')
    const maxNumberGlobalLegend = document.getElementById('max-number-global-legend')
    if (maxNumberGlobalRadioLimited.checked) {
        maxNumberGlobalLegend.textContent = `The global ownership of ${itemName} is limited.`
        document.getElementById("max-number-global-settings").style.display = '';
    } else {
        maxNumberGlobalLegend.textContent = `There is no global ownership limit for ${itemName}.`
        document.getElementById("max-number-global-settings").style.display = 'none';
    }

    const nameSpanList = document.querySelectorAll('.item-name');
    for (let i = 0; i < nameSpanList.length; i++) {
        nameSpanList[i].textContent = itemName;
    }


}

function generateOutput() {
    const itemValue = chooseItemSelect.value;
    //let outString = ""
    //if (itemValue.charAt(7) === 'u') {
    //    outString = `unitTypeBuild[${itemValue}.id] = {`
    //} else if (itemValue.charAt(7) === 'i') {
    //    outString = `improvementBuild[${itemValue}.id] = {`
    //} else if (itemValue.charAt(7) === 'w') {
    //    outString = `wonderBuild[${itemValue}.id] = {`
    //}
    let outString = `addBuildConditions(${itemValue}, {`
    outString += computeForbiddenTribesCode();
    outString += computeForbiddenMapsCode();
    outString += computeLocationCode();
    outString += computeForbiddenLocationCode();
    outString += computeAllImprovementsCode();
    outString += computeSomeImprovementsCode();
    outString += computeForbiddenImprovementsCode();
    outString += computeAllWondersCode();
    outString += computeSomeWondersCode();
    outString += computeAllTechsCode();
    outString += computeSomeTechsCode();
    outString += computeForbiddenTechsCode();
    outString += computeAllFlagsMatchCode();
    outString += computeSomeFlagsMatchCode();
    outString += computeMinimumPopulationCode();
    outString += computeMaximumPopulationCode();
    outString += computeFirstTurnCode();
    outString += computeLastTurnCode();
    outString += computeForbiddenAlternateProductionCode();
    outString += computeRequireSomeAsAlternateProductionCode();
    outString += computeTribeLimitedOwnershipCode();
    outString += computeGlobalLimitedOwnershipCode();
    outString += computeBinarySettings();
    outString += '})\n'
    settingOutputCode.textContent = outString;
}

function makeListCodeGenerator(selectElement,keyString,textElement,textKeyString) {
    const radioName = document.getElementById(selectElement.id.replace('select','radio-name'));
    //const radioConstructor = document.getElementById(selectElement.id.replace('select','radio-constructor'));
    const outputFunction = function() {
        // if no list selected, no code should be generated
        if (!selectElement.value) {
            return "";
        }
        let output = keyString + " = ";
        if (radioName.checked) {
            output = output+getListObjectFromFixedId(selectElement.value).code;
        } else {
            output = output + generateListConstructor(getListObjectFromFixedId(selectElement.value))
            //console.log(selectElement.value,typeof selectElement.value)
            //let listCode = generateListCode(getListObjectFromFixedId(selectElement.value))
            //listCode = listCode.substring(6,listCode.length);
            //output = output + listCode;
        }
        output = output+", ";
        if (textElement) {
            output = output+`${textKeyString} = ${textElement.value || 0}, `
        }
        return output;
    }
    return outputFunction
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


function makeListEntry(parentNode,listStorageArray,codeName,selectArrayList){
    listStorageArray.push(codeName);
    displayAllEntryLists();
}


function updateValidSelection(listStorageArray,selectElementList) {
    for (let i = 0; i < selectElementList.length; i++) {
        const options = selectElementList[i].children;
        for (let j=0; j < options.length; j++) {
            if (listStorageArray.includes(options[j].value)) {
                options[j].hidden = true;
            } else {
                options[j].hidden = false;
            }
        }
    }
}

function displayEntryList(entryList,listStorageArray,selectElementList) {
    deleteAllChildren(entryList);
    updateValidSelection(listStorageArray,selectElementList)
    for (let i = 0; i <  listStorageArray.length; i++) {
        const li = document.createElement('li');
        const removeButton = document.createElement('button');
        removeButton.textContent = "remove"
        const nameSpan = document.createElement('span');
        const codeName = listStorageArray[i];
        nameSpan.textContent = fullList[codeName].name;
        li.appendChild(nameSpan);
        li.appendChild(removeButton);
        removeButton.addEventListener('click', e => {
            removeArrayValue(listStorageArray,codeName);
            displayAllEntryLists();
            //selectElementList.forEach(selectArray => unhideSelection(selectArray,codeName));
            li.remove();
            updateAllListSelectors();
            updateValidSelection(listStorageArray,selectElementList);
        });
        if (entryList.children[0]) {
            entryList.insertBefore(li,entryList.children[0]);
        } else {
            entryList.appendChild(li);
        }
    }
}
const displayEntryListFunctionArray = [];
function displayAllEntryLists() {
    displayEntryListFunctionArray.forEach( fn => { fn() });
}
let listNumberCount = 0;

function makeListCreatorForm(listObject) {
    const listStorageArray = listObject.listStorageArray
    const optionsArraysTitles = listObject.optionsArraysTitles;
    const optionsArrays = listObject.optionsArrays;
    const listCode = listObject.code
    listNumberCount ++;
    const makeListForm = document.createElement('div');
    const closeEditButton = document.createElement('button')
    makeListForm.appendChild(closeEditButton);
    closeEditButton.textContent = "Stop Editing List";
    const listNameDiv = document.createElement('div');
    const listNameLabel = document.createElement('label');
    listNameLabel.htmlFor = `list-name-${listNumberCount}`;
    listNameLabel.textContent = "Change Variable Name:";
    listNameDiv.appendChild(listNameLabel);
    const listNameInput = document.createElement('input');
    listNameInput.type = "text";
    listNameInput.id = `list-name-${listNumberCount}`;
    listNameInput.className="variable-name-input";
    listNameInput.value = listCode;
    listNameDiv.appendChild(listNameInput);
    const listNameHint = document.createElement('span')
    const listNameBreak = document.createElement('br')
    listNameInput.addEventListener('input', e => {
        listObject.code = listNameInput.value;
        makeListCatalogueBox();
        if (isInvalidVariableName(listObject.code)) {
            listNameHint.hidden = false;
            listNameBreak.hidden = false;
        } else {
            listNameHint.hidden = true;
            listNameBreak.hidden = true;
        }
        updateAllListSelectors();
    });
    listNameDiv.appendChild(listNameBreak);
    listNameDiv.appendChild(listNameHint);
    listNameHint.textContent = "The list variable name must consist only of letters, numbers, and underscores, and must not begin with a number.";
    listNameHint.style.color = 'red';
    if (isInvalidVariableName(listObject.code)) {
        listNameHint.hidden = false;
        listNameBreak.hidden = false;
    } else {
        listNameHint.hidden = true;
        listNameBreak.hidden = true;
    }
    makeListForm.appendChild(listNameDiv);
    closeEditButton.addEventListener('click', e => {
        makeListForm.parentNode.removeChild(makeListForm);
        listObject.editing = false;
        makeListCatalogueBox();
    });
    //makeListForm.appendChild(document.createElement('br'))
    const selectElementList = []
    const emptyChoiceList = []
    for (let i = 0; i < optionsArrays.length; i++) {
        const selectElement = document.createElement('select')
        const emptyChoice = document.createElement('option')
        emptyChoice.value = "";
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
    displayEntryList(entryList,listStorageArray,selectElementList);
    displayEntryListFunctionArray.push( () => displayEntryList(entryList,listStorageArray,selectElementList));
    makeListForm.appendChild(document.createElement('br'));
    makeListForm.appendChild(entryList);
    addButton.addEventListener('click',e => {
        makeListEntry(entryList,listStorageArray,choiceSpan.value,selectElementList);
        for (let i = 0; i < emptyChoiceList.length; i++) {
            emptyChoiceList[i].selected = true;
            choiceSpan.value = "";
            choiceSpan.textContent = "";
            addButton.disabled = true;
        }
        updateAllListSelectors();
    });
    return makeListForm;
}

const updateListSelectorFnArray = [];

function updateAllListSelectors() {
    updateListSelectorFnArray.forEach(updateFn => updateFn());
}

// Select Fields

const locationSelect = document.getElementById('location-select');
addRadioButtonsAfter(locationSelect);
const arrayOfOnlyCitiesAllowed = [];
const arrayOfOnlyCitiesAllowedTitles = [];
addCitiesToArrayOfAllowed(arrayOfOnlyCitiesAllowed,arrayOfOnlyCitiesAllowedTitles);
updateListSelectorFnArray.push( () => updateListSelector(locationSelect,arrayOfOnlyCitiesAllowed.flat()))
locationSelect.addEventListener('change', e => {
    if (locationSelect.value === 'new-list') {
        newListEventAllCities(locationSelect,[],[],"onlyBuildInTheseCities");
    }
});
const computeLocationCode = makeListCodeGenerator(locationSelect,"location",false,false);
const forbiddenLocationSelect = document.getElementById('forbidden-location-select');
addRadioButtonsAfter(forbiddenLocationSelect);
updateListSelectorFnArray.push( () => updateListSelector(forbiddenLocationSelect,arrayOfOnlyCitiesAllowed.flat()))
forbiddenLocationSelect.addEventListener('change', e => {
    if (forbiddenLocationSelect.value === 'new-list') {
        newListEventAllCities(forbiddenLocationSelect,[],[],"canNotBuildInTheseCities");
    }
});
const computeForbiddenLocationCode = makeListCodeGenerator(forbiddenLocationSelect,"forbiddenLocation",false,false);

const allImprovementsSelect = document.getElementById('all-improvements-select');
addRadioButtonsAfter(allImprovementsSelect);
const improvementsWonders = [improvementList,wonderList];
const improvementsWondersTitles = ["Improvements","Wonders"];
updateListSelectorFnArray.push( () => updateListSelector(allImprovementsSelect,improvementsWonders.flat()) )
allImprovementsSelect.addEventListener('change', e => {
    if (allImprovementsSelect.value === 'new-list') {
        newListEvent(allImprovementsSelect,improvementsWonders,improvementsWondersTitles,'allImprovementsNeeded');
    }
});
const computeAllImprovementsCode = makeListCodeGenerator(allImprovementsSelect,"allImprovements",false,false);

const someImprovementsSelect = document.getElementById('some-improvements-select');
addRadioButtonsAfter(someImprovementsSelect);
updateListSelectorFnArray.push( () => updateListSelector(someImprovementsSelect,improvementsWonders.flat()) )
someImprovementsSelect.addEventListener('change', e => {
    if (someImprovementsSelect.value === 'new-list') {
        newListEvent(someImprovementsSelect,improvementsWonders,improvementsWondersTitles,'someImprovementsNeeded');
    }
});
const computeSomeImprovementsCode = makeListCodeGenerator(someImprovementsSelect,"someImprovements",document.getElementById('number-of-improvements'),'numberOfImprovements');

const forbiddenImprovementsSelect = document.getElementById('forbidden-improvements-select');
addRadioButtonsAfter(forbiddenImprovementsSelect);
updateListSelectorFnArray.push( () => updateListSelector(forbiddenImprovementsSelect,improvementsWonders.flat()) )
forbiddenImprovementsSelect.addEventListener('change', e => {
    if (forbiddenImprovementsSelect.value === 'new-list') {
        newListEvent(forbiddenImprovementsSelect,improvementsWonders,improvementsWondersTitles,'forbiddenImprovements');
    }
});
const computeForbiddenImprovementsCode = makeListCodeGenerator(forbiddenImprovementsSelect,"forbiddenImprovements",false,false);

const allWondersSelect = document.getElementById('all-wonders-select');
addRadioButtonsAfter(allWondersSelect);
const wondersOnly = [wonderList];
const wondersOnlyTitles = ["Wonders"];
updateListSelectorFnArray.push( () => updateListSelector(allWondersSelect,wondersOnly.flat()) )
allWondersSelect.addEventListener('change', e => {
    if (allWondersSelect.value === 'new-list') {
        newListEvent(allWondersSelect,wondersOnly,wondersOnlyTitles,'allWondersNeeded');
    }
});
const computeAllWondersCode = makeListCodeGenerator(allWondersSelect,"allWonders",false,false);
const someWondersSelect = document.getElementById('some-wonders-select');
addRadioButtonsAfter(someWondersSelect);
updateListSelectorFnArray.push( () => updateListSelector(someWondersSelect,wondersOnly.flat()) )
someWondersSelect.addEventListener('change', e => {
    if (someWondersSelect.value === 'new-list') {
        newListEvent(someWondersSelect,wondersOnly,wondersOnlyTitles,'someWondersNeeded');
    }
});
const computeSomeWondersCode = makeListCodeGenerator(someWondersSelect,"someWonders",document.getElementById('number-of-wonders'),"numberOfWonders");
const allTechsSelect = document.getElementById('all-techs-select');
addRadioButtonsAfter(allTechsSelect);
const advancesOnly = [advancesList];
const advancesOnlyTitles = ["Advances"];
updateListSelectorFnArray.push( () => updateListSelector(allTechsSelect,advancesOnly.flat()) )
allTechsSelect.addEventListener('change', e => {
    if (allTechsSelect.value === 'new-list') {
        newListEvent(allTechsSelect,advancesOnly,advancesOnlyTitles,'allAdvancesNeeded');
    }
});
const computeAllTechsCode = makeListCodeGenerator(allTechsSelect,"allTechs",false,false);
const someTechsSelect = document.getElementById('some-techs-select');
addRadioButtonsAfter(someTechsSelect);
updateListSelectorFnArray.push( () => updateListSelector(someTechsSelect,advancesOnly.flat()) )
someTechsSelect.addEventListener('change', e => {
    if (someTechsSelect.value === 'new-list') {
        newListEvent(someTechsSelect,advancesOnly,advancesOnlyTitles,'someAdvancesNeeded');
    }
});
const computeSomeTechsCode = makeListCodeGenerator(someTechsSelect,"someTechs",document.getElementById('number-of-techs'),"numberOfTechs");

const forbiddenTechsSelect = document.getElementById('forbidden-techs-select');
addRadioButtonsAfter(forbiddenTechsSelect);
updateListSelectorFnArray.push( () => updateListSelector(forbiddenTechsSelect,advancesOnly.flat()) )
forbiddenTechsSelect.addEventListener('change', e => {
    if (forbiddenTechsSelect.value === 'new-list') {
        newListEvent(forbiddenTechsSelect,advancesOnly,advancesOnlyTitles,'forbiddenAdvances');
    }
});
const computeForbiddenTechsCode = makeListCodeGenerator(forbiddenTechsSelect,"forbiddenTechs",false,false);


const allFlagsMatchSelect = document.getElementById('all-flags-match-select');
const flagsOnly = [flagsList];
const flagsOnlyTitles = ["Flags"];
const allFlagsMatchList = document.getElementById('all-flags-match-list')
updateListSelectorFnArray.push( () => {
    updateListSelector(allFlagsMatchSelect,flagsOnly.flat());
    updateFlagRadio(allFlagsMatchSelect,allFlagsMatchList);
});
allFlagsMatchSelect.addEventListener('change', e => {
    if (allFlagsMatchSelect.value === 'new-list') {
        newListEvent(allFlagsMatchSelect,flagsOnly,flagsOnlyTitles,'requiredFlags');
    }
    updateAllListSelectors();
});
function computeAllFlagsMatchCode() {
    if (!allFlagsMatchSelect.value || allFlagsMatchList.children.length === 0) {
        return "";
    }
    let output = "allFlagsMatch = ";
    output = output+generateFlagRadioCode(allFlagsMatchList)+", ";
    return output;
}


const someFlagsMatchSelect = document.getElementById('some-flags-match-select');
const someFlagsMatchList = document.getElementById('some-flags-match-list');
updateListSelectorFnArray.push( () => {
    updateListSelector(someFlagsMatchSelect,flagsOnly.flat());
    updateFlagRadio(someFlagsMatchSelect,someFlagsMatchList);
});
someFlagsMatchSelect.addEventListener('change', e => {
    if (someFlagsMatchSelect.value === 'new-list') {
        newListEvent(someFlagsMatchSelect,flagsOnly,flagsOnlyTitles,'someFlagsNeeded');
    }
    updateAllListSelectors();
});
function computeSomeFlagsMatchCode() {
    if (!someFlagsMatchSelect.value || someFlagsMatchList.children.length === 0) {
        return "";
    }
    let output = "someFlagsMatch = ";
    output = output+generateFlagRadioCode(someFlagsMatchList)+", ";
    output = output+`numberOfFlags = ${document.getElementById('some-flags-match-select')}, `
    return output;
}

const forbiddenAlternateProductionSelect = document.getElementById('forbidden-alternate-production-select');
addRadioButtonsAfter(forbiddenAlternateProductionSelect);
const buildableItemsOnly = [unitList,improvementList,wonderList];
const buildableItemsOnlyTitles = ["Units","Improvements","Wonders"];
updateListSelectorFnArray.push( () => updateListSelector(forbiddenAlternateProductionSelect,buildableItemsOnly.flat()) )
forbiddenAlternateProductionSelect.addEventListener('change', e => {
    if (forbiddenAlternateProductionSelect.value === 'new-list') {
        newListEvent(forbiddenAlternateProductionSelect,buildableItemsOnly,buildableItemsOnlyTitles,'forbiddenAlternateProduction');
    }
});
const computeForbiddenAlternateProductionCode = makeListCodeGenerator(forbiddenAlternateProductionSelect,"forbiddenAlternateProduction",false,false);

const requireSomeAsAlternateProductionSelect = document.getElementById('require-some-as-alternate-production-select');
addRadioButtonsAfter(requireSomeAsAlternateProductionSelect);
updateListSelectorFnArray.push( () => updateListSelector(requireSomeAsAlternateProductionSelect,buildableItemsOnly.flat()) )
requireSomeAsAlternateProductionSelect.addEventListener('change', e => {
    if (requireSomeAsAlternateProductionSelect.value === 'new-list') {
        newListEvent(requireSomeAsAlternateProductionSelect,buildableItemsOnly,buildableItemsOnlyTitles,'requiredAlternateProduction');
    }
});
const computeRequireSomeAsAlternateProductionCode = makeListCodeGenerator(requireSomeAsAlternateProductionSelect,"requireSomeAsAlternateProduction",document.getElementById('number-of-alternate-production'),"numberOfAlternateProduction");

// Search For Tribe Totals

const maxNumberTribeTribeTotalsSelect = document.getElementById("max-number-tribe-tribe-totals-select");
const totalsOptions = [unitList,improvementList,wonderList,advancesList,tribeList];
const totalsTitles = ["Units","Improvements","Wonders","Technologies","Tribes"];
const maxNumberTribeTribeTotalsList = document.getElementById("max-number-tribe-tribe-totals-list");
function tribeTotalsDescription(itemCode,itemName) {
    if (itemCode.substring(0,8) === "object.u") {
        return `For each ${itemName} owned by the tribe, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.p") {
        return `Increase the ownership limit of the ${itemName} by this amount.`;
    } else if (itemCode.substring(0,8) === "object.i") {
        return `For each ${itemName} owned by the tribe, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.w") {
        return `If the tribe owns the ${itemName}, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.a") {
        return `If the tribe has ${itemName}, increase the ownership limit by this amount.`;
    }
    return "No description"
}
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeTribeTotalsSelect,totalsOptions.flat());
    updateFloatInput(maxNumberTribeTribeTotalsSelect,maxNumberTribeTribeTotalsList,tribeTotalsDescription);
});
maxNumberTribeTribeTotalsSelect.addEventListener('change', e => {
    if (maxNumberTribeTribeTotalsSelect.value === 'new-list') {
        newListEvent(maxNumberTribeTribeTotalsSelect,totalsOptions,totalsTitles,'tribePosessionsIncrements');
    }
    updateAllListSelectors();
});
const maxNumberTribeGlobalTotalsSelect = document.getElementById("max-number-tribe-global-totals-select");
const maxNumberTribeGlobalTotalsList = document.getElementById("max-number-tribe-global-totals-list");
function globalTotalsDescription(itemCode,itemName) {
    if (itemCode.substring(0,8) === "object.u") {
        return `For each ${itemName} owned by the anyone, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.p") {
        return `If the ${itemName} are still active, increase the ownership limit by this amount`;
    } else if (itemCode.substring(0,8) === "object.i") {
        return `For each ${itemName} owned by the anyone, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.w") {
        return `If any tribe owns the ${itemName}, increase the ownership limit by this amount.`;
    } else if (itemCode.substring(0,8) === "object.a") {
        return `For each tribe that has ${itemName}, increase the ownership limit by this amount.`;
    }
    return "No description"
}
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeGlobalTotalsSelect,totalsOptions.flat());
    updateFloatInput(maxNumberTribeGlobalTotalsSelect,maxNumberTribeGlobalTotalsList,globalTotalsDescription);
});
maxNumberTribeGlobalTotalsSelect.addEventListener('change', e => {
    if (maxNumberTribeGlobalTotalsSelect.value === 'new-list') {
        newListEvent(maxNumberTribeGlobalTotalsSelect,totalsOptions,totalsTitles,'globalPosessionsIncrements');
    }
    updateAllListSelectors();
});
const maxNumberTribeActiveWondersTribeSelect = document.getElementById("max-number-tribe-active-wonders-tribe-select");
const maxNumberTribeActiveWondersTribeList = document.getElementById("max-number-tribe-active-wonders-tribe-list")
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeActiveWondersTribeSelect,wonderList);
    updateFloatInput(maxNumberTribeActiveWondersTribeSelect,maxNumberTribeActiveWondersTribeList);
});
maxNumberTribeActiveWondersTribeSelect.addEventListener('change', e => {
    if (maxNumberTribeActiveWondersTribeSelect.value === 'new-list') {
        newListEvent(maxNumberTribeActiveWondersTribeSelect,[wonderList],["Wonders"],"globalActiveWonderIncrements")
    }
    updateAllListSelectors();
});
const maxNumberTribeActiveWondersForeignSelect = document.getElementById("max-number-tribe-active-wonders-foreign-select");
const maxNumberTribeActiveWondersForeignList = document.getElementById("max-number-tribe-active-wonders-foreign-list")
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeActiveWondersForeignSelect,wonderList);
    updateFloatInput(maxNumberTribeActiveWondersForeignSelect,maxNumberTribeActiveWondersForeignList);
});
maxNumberTribeActiveWondersForeignSelect.addEventListener('change', e => {
    if (maxNumberTribeActiveWondersForeignSelect.value === 'new-list') {
        newListEvent(maxNumberTribeActiveWondersForeignSelect,[wonderList],["Wonders"],"tribeForeignWonderIncrements")
    }
    updateAllListSelectors();
});

const maxNumberTribeDiscoveredTechsSelect = document.getElementById("max-number-tribe-discovered-techs-select");
const maxNumberTribeDiscoveredTechsList = document.getElementById("max-number-tribe-discovered-techs-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeDiscoveredTechsSelect,advancesList);
    updateFloatInput(maxNumberTribeDiscoveredTechsSelect,maxNumberTribeDiscoveredTechsList);
});
maxNumberTribeDiscoveredTechsSelect.addEventListener('change', e => {
    if (maxNumberTribeDiscoveredTechsSelect.value === 'new-list') {

        newListEvent(maxNumberTribeDiscoveredTechsSelect,[advancesList],["Technologies"], "tribeIncrementsDiscoveredTechs");
    }
    updateAllListSelectors();
});
const maxNumberTribeTrueFlagsSelect = document.getElementById("max-number-tribe-true-flags-select");
const maxNumberTribeTrueFlagsList = document.getElementById("max-number-tribe-true-flags-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeTrueFlagsSelect,flagsList);
    updateFloatInput(maxNumberTribeTrueFlagsSelect,maxNumberTribeTrueFlagsList);
});
maxNumberTribeTrueFlagsSelect.addEventListener('change', e => {
    if (maxNumberTribeTrueFlagsSelect.value === 'new-list') {

        newListEvent(maxNumberTribeTrueFlagsSelect,[flagsList],["Flags"], "tribeIncrementsTrueFlags");
    }
    updateAllListSelectors();
});

const maxNumberTribeCounterValuesSelect = document.getElementById("max-number-tribe-counter-values-select");
const maxNumberTribeCounterValuesList = document.getElementById("max-number-tribe-counter-values-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeCounterValuesSelect,countersList);
    updateFloatInput(maxNumberTribeCounterValuesSelect,maxNumberTribeCounterValuesList);
});
maxNumberTribeCounterValuesSelect.addEventListener('change', e => {
    if (maxNumberTribeCounterValuesSelect.value === 'new-list') {

        newListEvent(maxNumberTribeCounterValuesSelect,[countersList],["Counters"], "tribeIncrementsCounterValues");
    }
    updateAllListSelectors();
});


const maxNumberTribeSharedLimitSelect = document.getElementById("max-number-tribe-shared-limit-select");
const productionOptions = [unitList,improvementList,wonderList];
const productionTitles = ["Units","Improvements","Wonders"];
const maxNumberTribeSharedLimitList = document.getElementById("max-number-tribe-shared-limit-list");
function tribeSharedLimitsDescription(itemCode,itemName) {
    const chooseItemName = fullList[chooseItemSelect.value].name;
    if (itemCode === chooseItemSelect.value) {
        if (itemCode.substring(0,8) === "object.u") {
            return `Each ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        } else if (itemCode.substring(0,8) === "object.i") {
            return `Each ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        } else if (itemCode.substring(0,8) === "object.w") {
            return `The ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        }
        return "No description"
    } else {
        if (itemCode.substring(0,8) === "object.u") {
            return `Each ${itemName} onwed by the tribe uses this quantity of the ${chooseItemName} ownership limit.`;
        } else if (itemCode.substring(0,8) === "object.i") {
            return `Each ${itemName} owned by the tribe uses this quantity of the ${chooseItemName} ownership limit.`;
        } else if (itemCode.substring(0,8) === "object.w") {
            return `If ${itemName} is onwed by the tribe, this quantity of the ${chooseItemName} ownership limit is used.`;
        }
        return "No description"
    }
}
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberTribeSharedLimitSelect,productionOptions.flat());
    updateFloatInput(maxNumberTribeSharedLimitSelect,maxNumberTribeSharedLimitList,tribeSharedLimitsDescription
    );
});
maxNumberTribeSharedLimitSelect.addEventListener('change', e => {
    if (maxNumberTribeSharedLimitSelect.value === 'new-list') {
        newListEvent(maxNumberTribeSharedLimitSelect,productionOptions,productionTitles,'tribeSharedLimitsList');
    }
    updateAllListSelectors();
});


function computeFloatInputTableInteriorCode(floatInputTableElement) {
    let output = ""
    for (let i = 0; i < floatInputTableElement.children.length; i++) {
        const tableElement = floatInputTableElement.children[i];
        const nameElement = tableElement.children[0];
        const floatInput = tableElement.children[1];
        output = output + `[${nameElement.value}] = ${floatInput.value}, `;
    }
    return output;
}

function computeTribeLimitedOwnershipCode() {
    if (maxNumberTribeRadioUnlimited.checked) {
        return "";
    }
    
    let output = "maxNumberTribe = {";
    let value = document.getElementById("max-number-tribe-base").value;
    if (value !== "0") {
        output = output + "base = "+ value + ", ";
    }
    value = document.getElementById("max-number-tribe-min").value
    if (value !== "0") {
        output = output + "min = "+ value + ", ";
    }
    value = document.getElementById("max-number-tribe-max").value;
    if (value !== "0") {
        output = output + "max = "+ value + ", ";
    }
    value = document.getElementById("max-number-tribe-turn-increment" ).value;
    if (value !== "0") {
        output = output + "turn = "+ value + ", ";
    }
    output = output + "tribeTotals = {";
    value = document.getElementById("max-number-tribe-tribe-cities-increment").value;
    if (value !== "0") {
        output = output + "[\"cities\"] = "+ value + ", ";
    }
    value = document.getElementById("max-number-tribe-tribe-population-increment").value;
    if (value !== "0") {
        output = output + "[\"population\"] = "+ value + ", ";
    }
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeTribeTotalsList);
    output = output + "},";
    let emptyTable = "tribeTotals = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "globalTotals = {";
    value = document.getElementById("max-number-tribe-global-cities-increment").value;
    if (value !== "0") {
        output = output + "[\"cities\"] = "+ value + ", ";
    }
    value = document.getElementById("max-number-tribe-global-population-increment").value;
    if (value !== "0") {
        output = output + "[\"population\"] = "+ value + ", ";
    }
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeGlobalTotalsList);
    output = output + "},";
    emptyTable = "globalTotals = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "activeWondersTribe = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeActiveWondersTribeList);
    output = output + "},";
    emptyTable = "activeWondersTribe = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "activeWondersForeign = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeActiveWondersForeignList);
    output = output + "},";
    emptyTable = "activeWondersForeign = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }

    output = output + "discoveredTechs = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeDiscoveredTechsList);
    output = output + "},";
    emptyTable = "discoveredTechs = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "trueFlags = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeTrueFlagsList);
    output = output + "},";
    emptyTable = "trueFlags = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    
    output = output + "counterValues = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeCounterValuesList);
    output = output + "},";
    emptyTable = "counterValues = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }

    // end of maxNumberTribe key
    output = output + "}, ";

    output = output + "tribeJointMaxWith = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberTribeSharedLimitList);
    output = output + "},";
    emptyTable = "tribeJointMaxWith = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    
    return output;
}

const maxNumberGlobalGlobalTotalsSelect = document.getElementById("max-number-global-global-totals-select");
const maxNumberGlobalGlobalTotalsList = document.getElementById("max-number-global-global-totals-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalGlobalTotalsSelect, totalsOptions.flat());
    updateFloatInput(maxNumberGlobalGlobalTotalsSelect,maxNumberGlobalGlobalTotalsList,globalTotalsDescription);
});
maxNumberGlobalGlobalTotalsSelect.addEventListener('change', e => {
    if (maxNumberGlobalGlobalTotalsSelect.value === 'new-list') {
        newListEvent(maxNumberGlobalGlobalTotalsSelect,totalsOptions,totalsTitles, 'worldPosessionsIncrements');
    }
});

const maxNumberGlobalActiveWondersSelect = document.getElementById("max-number-global-active-wonders-select");
const maxNumberGlobalActiveWondersList = document.getElementById("max-number-global-active-wonders-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalActiveWondersSelect,wonderList);
    updateFloatInput(maxNumberGlobalActiveWondersSelect,maxNumberGlobalActiveWondersList);
});
maxNumberGlobalActiveWondersSelect.addEventListener('change', e => {
    if (maxNumberGlobalActiveWondersSelect.value === 'new-list') {
        newListEvent(maxNumberGlobalActiveWondersSelect,[wonderList],["Wonders"],"tribeActiveWonderIncrements");
    }
    updateAllListSelectors();

});

const maxNumberGlobalDiscoveredTechsSelect = document.getElementById("max-number-global-discovered-techs-select");
const maxNumberGlobalDiscoveredTechsList = document.getElementById("max-number-global-discovered-techs-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalDiscoveredTechsSelect,advancesList);
    updateFloatInput(maxNumberGlobalDiscoveredTechsSelect,maxNumberGlobalDiscoveredTechsList);
});
maxNumberGlobalDiscoveredTechsSelect.addEventListener('change', e => {
    if (maxNumberGlobalDiscoveredTechsSelect.value === 'new-list') {
        newListEvent(maxNumberGlobalDiscoveredTechsSelect,[advancesList],["Technologies"], "globalIncrementsDiscoveredTechs");
    }
    updateAllListSelectors();
});

const maxNumberGlobalTrueFlagsSelect = document.getElementById("max-number-global-true-flags-select");
const maxNumberGlobalTrueFlagsList = document.getElementById("max-number-global-true-flags-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalTrueFlagsSelect,flagsList);
    updateFloatInput(maxNumberGlobalTrueFlagsSelect,maxNumberGlobalTrueFlagsList);
});
maxNumberGlobalTrueFlagsSelect.addEventListener('change', e => {
    if (maxNumberGlobalTrueFlagsSelect.value === 'new-list') {

        newListEvent(maxNumberGlobalTrueFlagsSelect,[flagsList],["Flags"], "globalIncrementsTrueFlags");
    }
    updateAllListSelectors();
});

const maxNumberGlobalCounterValuesSelect = document.getElementById("max-number-global-counter-values-select");
const maxNumberGlobalCounterValuesList = document.getElementById("max-number-global-counter-values-list");
updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalCounterValuesSelect,countersList);
    updateFloatInput(maxNumberGlobalCounterValuesSelect,maxNumberGlobalCounterValuesList);
});
maxNumberGlobalCounterValuesSelect.addEventListener('change', e => {
    if (maxNumberGlobalCounterValuesSelect.value === 'new-list') {

        newListEvent(maxNumberGlobalCounterValuesSelect,[countersList],["Counters"], "globalIncrementsCounterValues");
    }
    updateAllListSelectors();
});

const maxNumberGlobalSharedLimitSelect = document.getElementById("max-number-global-shared-limit-select");
const maxNumberGlobalSharedLimitList = document.getElementById("max-number-global-shared-limit-list");
function globalSharedLimitsDescription(itemCode,itemName) {
    const chooseItemName = fullList[chooseItemSelect.value].name;
    if (itemCode === chooseItemSelect.value) {
        if (itemCode.substring(0,8) === "object.u") {
            return `Each ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        } else if (itemCode.substring(0,8) === "object.i") {
            return `Each ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        } else if (itemCode.substring(0,8) === "object.w") {
            return `The ${itemName} consumes this much of the calculated ownership limit, instead of 1 unit.`;
        }
        return "No description"
    } else {
        if (itemCode.substring(0,8) === "object.u") {
            return `Each ${itemName} onwed by anyone uses this quantity of the ${chooseItemName} global ownership limit.`;
        } else if (itemCode.substring(0,8) === "object.i") {
            return `Each ${itemName} owned by anyone uses this quantity of the ${chooseItemName} global ownership limit.`;
        } else if (itemCode.substring(0,8) === "object.w") {
            return `If ${itemName} is onwed by anyone, this quantity of the ${chooseItemName} global ownership limit is used.`;
        }
        return "No description"
    }
}

updateListSelectorFnArray.push( () => {
    updateListSelector(maxNumberGlobalSharedLimitSelect,productionOptions.flat());
    updateFloatInput(maxNumberGlobalSharedLimitSelect,maxNumberGlobalSharedLimitList,globalSharedLimitsDescription
    );
});
maxNumberGlobalSharedLimitSelect.addEventListener('change', e => {
    if (maxNumberGlobalSharedLimitSelect.value === 'new-list') {
        newListEvent(maxNumberGlobalSharedLimitSelect,productionOptions,productionTitles,'globalSharedLimitsList');
    }
    updateAllListSelectors();
});

function computeGlobalLimitedOwnershipCode() {
    if (maxNumberGlobalRadioUnlimited.checked) {
        return "";
    }
    let output = "maxNumberGlobal = {";
    let value = document.getElementById("max-number-global-base").value;
    if (value !== "0") {
        output = output + "base = "+ value + ", ";
    }
    value = document.getElementById("max-number-global-min").value
    if (value !== "0") {
        output = output + "min = "+ value + ", ";
    }
    value = document.getElementById("max-number-global-max").value;
    if (value !== "0") {
        output = output + "max = "+ value + ", ";
    }
    value = document.getElementById("max-number-global-turn-increment" ).value;
    if (value !== "0") {
        output = output + "turn = "+ value + ", ";
    }
    output = output + "globalTotals = {";
    value = document.getElementById("max-number-global-global-cities-increment").value;
    if (value !== "0") {
        output = output + "[\"cities\"] = "+ value + ", ";
    }
    value = document.getElementById("max-number-global-global-population-increment").value;
    if (value !== "0") {
        output = output + "[\"population\"] = "+ value + ", ";
    }
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalGlobalTotalsList);
    output = output + "},";
    let emptyTable = "globalTotals = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "activeWonders = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalActiveWondersList);
    output = output + "},";
    emptyTable = "activeWonders = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "discoveredTechs = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalDiscoveredTechsList);
    output = output + "},";
    emptyTable = "discoveredTechs = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    output = output + "trueFlags = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalTrueFlagsList);
    output = output + "},";
    emptyTable = "trueFlags = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    
    output = output + "counterValues = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalCounterValuesList);
    output = output + "},";
    emptyTable = "counterValues = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }

    // end of maxNumberGlobal key
    output = output + "}, ";

    output = output + "globalJointMaxWith = {";
    output = output + computeFloatInputTableInteriorCode(maxNumberGlobalSharedLimitList);
    output = output + "},";
    emptyTable = "globalJointMaxWith = {"+"},";
    if (output.substring(output.length-emptyTable.length,output.length) === emptyTable) {
        output = output.substring(0,output.length-emptyTable.length);
    }
    return output;
}


function addRadioButtonsAfter(selectElement) {
    const radioName = document.createElement('input');
    radioName.type="radio";
    radioName.name=selectElement.id.replace('select','choose-variable-name-or-constructor');
    radioName.id=selectElement.id.replace('select','radio-name');
    radioName.value="name";
    const radioNameLabel = document.createElement('label');
    radioNameLabel.htmlFor = radioName.id
    radioNameLabel.textContent = "Use list variable name."
    const radioConstructor = document.createElement('input');
    radioConstructor.type="radio";
    radioConstructor.name=selectElement.id.replace('select','choose-variable-name-or-constructor');
    radioConstructor.id=selectElement.id.replace('select','radio-constructor');
    radioConstructor.value="constructor";
    const radioConstructorLabel = document.createElement('label');
    radioConstructorLabel.htmlFor = radioConstructor.id
    radioConstructorLabel.textContent = "Use list constructor."
    radioConstructor.checked=true;
    const selectParent = selectElement.parentNode;
    //selectParent.appendChild(radioConstructor);
    //selectParent.appendChild(radioConstructorLabel);
    //selectParent.appendChild(radioName);
    //selectParent.appendChild(radioNameLabel);
    selectParent.insertBefore(radioNameLabel,selectElement);
    selectParent.insertBefore(radioName,radioNameLabel);
    selectParent.insertBefore(radioConstructorLabel,radioName);
    selectParent.insertBefore(radioConstructor,radioConstructorLabel);
    selectParent.insertBefore(selectElement,radioConstructor);

}



function newListEventAllCities(selectElement,arrayOfOtherAllowed,arrayOfOtherAllowedTitles,newName) {
    const newListObject = new ListObject();
    listsCatalogueArray.push(newListObject);
    addCityLists(newListObject);
    for (let i = 0; i < arrayOfOtherAllowed.length; i++) {
        newListObject.addOption(arrayOfOtherAllowed[i],arrayOfOtherAllowedTitles[i])
    }
    newListObject.editing = true;
    newListObject.code = newName;
    // need the next 3 lines so that locationSelect.value will work
        const newChoice = document.createElement('option');
        newChoice.value = newListObject.fixedID;
        selectElement.appendChild(newChoice);
    selectElement.value = newListObject.fixedID;
    listGeneratorDiv.appendChild(makeListCreatorForm(newListObject));
    makeListCatalogueBox();
    updateAllListSelectors();
}

function newListEvent(selectElement,arrayOfAllowed,arrayOfAllowedTitles,newName) {
    const newListObject = new ListObject();
    listsCatalogueArray.push(newListObject);
    for (let i = 0; i < arrayOfAllowed.length; i++) {
        newListObject.addOption(arrayOfAllowed[i],arrayOfAllowedTitles[i]);
    }
    newListObject.editing = true;
    newListObject.code = newName;
    // need the next 3 lines so that locationSelect.value will work
        const newChoice = document.createElement('option');
        newChoice.value = newListObject.fixedID;
        selectElement.appendChild(newChoice);
    selectElement.value = newListObject.fixedID;
    listGeneratorDiv.appendChild(makeListCreatorForm(newListObject));
    makeListCatalogueBox();
    updateAllListSelectors();
}


updateAllListSelectors();



function optionInAllowedItems(optionCode,allowedItems) {
    for(let i = 0; i <allowedItems.length; i++) {
        if (allowedItems[i].code === optionCode) {
            return true;
        }
    }
    return false;
}

let testOption = ""

function listObjectHasOnlyAllowedItems(listObject,allowedItems) {
    const optionsArrays = listObject.optionsArrays;
    for (let optionArrayIndex = 0; optionArrayIndex < optionsArrays.length; optionArrayIndex++) {
        const optionArray = optionsArrays[optionArrayIndex];
        for (let optionIndex = 0; optionIndex < optionArray.length; optionIndex++){
            const optionCode = optionArray[optionIndex]["code"];
            if (!optionInAllowedItems(optionCode,allowedItems)) {
                return false;
            }
        }
    }
    return true;
}

function updateListSelector(selectElement,allowedItems) {
    const selectedListID = selectElement.value || "";
    deleteAllChildren(selectElement);
    const eligibleListObjects = [];
    for (let i = 0; i < listsCatalogueArray.length; i++) {
        const listObject = listsCatalogueArray[i];
        if (listObjectHasOnlyAllowedItems(listObject,allowedItems)) {
            eligibleListObjects.push(listObject);
        }
    }
    const emptyOption = document.createElement('option');
    selectElement.appendChild(emptyOption);
    emptyOption.textContent = "Not Applicable"
    emptyOption.value = ""
    let optionSelected = false
    for (let i = 0; i < eligibleListObjects.length; i++) {
        const optionElement = document.createElement('option');
        optionElement.value = eligibleListObjects[i].fixedID;
        optionElement.textContent = eligibleListObjects[i].code;
        if (optionElement.value === selectedListID) {
            optionElement.selected = true;
            optionSelected = true;
        }
        selectElement.appendChild(optionElement);
    }
    if (!optionSelected) {
        emptyOption.selected = true;
    }
    const newListOption = document.createElement('option');
    newListOption.textContent = "Create New List"
    newListOption.value = 'new-list';
    selectElement.appendChild(newListOption);
    return selectElement;
}

function addCitiesToArrayOfAllowed(arrayOfAllowed,arrayOfAllowedTitles) {
    for (let i = 0; i < 8; i++) {
        const tribeName = getItemWithId(i,tribeList).name 
        if (tribeName) {
            const tribeCities = [];
            cityLocationList.forEach(cityObject => {
                if (cityObject.tribeId === i) {
                    tribeCities.push(cityObject);
                    }
                });
            arrayOfAllowed.push(tribeCities);
            arrayOfAllowedTitles.push(`Cities (${tribeName})`);
        }
    }
}

function recordFlagRadioValue(flagLiElement,recordObject) {
    const nameSpan = document.getElementById(flagLiElement.id+"-name");
    const radioTrue = document.getElementById(flagLiElement.id+"-radio-true");
    const radioFalse = document.getElementById(flagLiElement.id+"-radio-false");
    const radioIgnore = document.getElementById(flagLiElement.id+"-radio-ignore");
    if (radioTrue.checked) {
        recordObject[nameSpan.value]="true";
        return ;
    } else if (radioFalse.checked) {
        recordObject[nameSpan.value]="false";
        return ;
    } else {
        recordObject[nameSpan.value]="ignore";
        return ;
    }
}

function generateFlagRadioCode(flagListElement) {
    const record = {}
    for (let i = 0; i < flagListElement.children.length; i++) {
        recordFlagRadioValue(flagListElement.children[i],record)
    }
    const entries = Object.entries(record);
    let output = "{";
    for (let i = 0; i < entries.length; i++) {
        if (entries[i][1] !== "ignore"){
            output = output+`[${entries[i][0]}]=${entries[i][1]}, `;
        }
    }
    output = output + "}";
    return output;
}

function updateFlagRadio(selectElement,flagListElement) {
    const previousSettings = {} // {code:("true" "false" "ignore")}
    for (let i = 0; i < flagListElement.children.length; i++) {
        recordFlagRadioValue(flagListElement.children[i],previousSettings);   
    }
    deleteAllChildren(flagListElement);
    if (!selectElement.value) {
        return ;
    }
    const listObject = getListObjectFromFixedId(selectElement.value)
    for (let i = 0; i < listObject.listStorageArray.length; i++) {
        const li = document.createElement('li');
        li.id=`${flagListElement.id}-li-${i}`
        flagListElement.appendChild(li);
        const elementName = document.createElement('span');
        elementName.textContent = fullList[listObject.listStorageArray[i]].name;
        elementName.value = listObject.listStorageArray[i];
        elementName.id = li.id+'-name';
        li.appendChild(elementName);
        const radioTrue = document.createElement('input');
        radioTrue.type="radio"
        radioTrue.id=li.id+"-radio-true";
        radioTrueLabel = document.createElement('label');
        radioTrueLabel.htmlFor = radioTrue.id;
        radioTrueLabel.textContent = "True";
        radioTrue.name = li.id+"-radio";
        li.appendChild(radioTrue);
        li.appendChild(radioTrueLabel);
        const radioFalse = document.createElement('input');
        radioFalse.type="radio"
        radioFalse.id=li.id+"-radio-false";
        radioFalseLabel = document.createElement('label');
        radioFalseLabel.htmlFor = radioFalse.id;
        radioFalseLabel.textContent = "False";
        radioFalse.name = li.id+"-radio";
        li.appendChild(radioFalse);
        li.appendChild(radioFalseLabel);
        const radioIgnore = document.createElement('input');
        radioIgnore.type="radio"
        radioIgnore.id=li.id+"-radio-ignore";
        radioIgnoreLabel = document.createElement('label');
        radioIgnoreLabel.htmlFor = radioIgnore.id;
        radioIgnoreLabel.textContent = "Ignore";
        radioIgnore.name = li.id+"-radio";
        li.appendChild(radioIgnore);
        li.appendChild(radioIgnoreLabel);
        if (previousSettings[listObject.listStorageArray[i]] === "true") {
            radioTrue.checked = true;
        } else if (previousSettings[listObject.listStorageArray[i]] === "false") {
            radioFalse.checked = true;
        } else {
            radioIgnore.checked = true;
        }
    }
}

function recordFloatInputValue(liElement,recordObject) {
    const nameSpan = document.getElementById(liElement.id+"-name");
    const floatInput = document.getElementById(liElement.id+"-float-input");
    recordObject[nameSpan.value]=floatInput.value
    return ;
}


// descriptionFunction(itemCode,itemName)
function updateFloatInput(selectElement,listElement,descriptionFunction) {

    descriptionFunction = descriptionFunction || function(itemCode,itemName) { return ""};
    const previousSettings = {} // {code: string}
    for (let i=0; i < listElement.children.length; i++) {
        recordFloatInputValue(listElement.children[i],previousSettings);
    }
    deleteAllChildren(listElement);
    if (!selectElement.value) {
        return ;
    }
    const listObject = getListObjectFromFixedId(selectElement.value)
    const itemName = fullList[chooseItemSelect.value].name;
    for (let i = 0; i < listObject.listStorageArray.length; i++) {
        const li = document.createElement('tr');
        li.id=`${listElement.id}-li-${i}`;
        listElement.appendChild(li);
        const elementName = document.createElement('td');
        elementName.textContent = fullList[listObject.listStorageArray[i]].name;
        elementName.value = listObject.listStorageArray[i];
        elementName.id = li.id+'-name';
        li.appendChild(elementName);
        const incrementFloatInput = document.createElement('input');
        incrementFloatInput.type = "text";
        incrementFloatInput.id = li.id+"-float-input";
        incrementFloatInput.className = "float-input";
        //incrementFloatInputLabel = document.createElement('label');
        //incrementFloatInputLabel.htmlFor = incrementFloatInput.id;
        //incrementFloatInputLabel.textContent = `For each ${elementName.textContent} owned by the tribe, increase the tribe's ownership limit of ${itemName} by:`;
        //li.appendChild(incrementFloatInputLabel);
        li.appendChild(incrementFloatInput);
        if (previousSettings[listObject.listStorageArray[i]]) {
            incrementFloatInput.value = previousSettings[listObject.listStorageArray[i]];
        } else if (elementName.value === chooseItemSelect.value) {
            incrementFloatInput.value = "1";
        } else {
            incrementFloatInput.value = "0";
        }
        const description = document.createElement('span');
        description.textContent = descriptionFunction(elementName.value,elementName.textContent);
        li.appendChild(description);


    }

}








const minimumPopulationInput = document.getElementById('minimum-population');
function computeMinimumPopulationCode() {
    if (minimumPopulationInput.value && parseInt(minimumPopulationInput.value) > 0 ) {
        return `minimumPopulation = ${minimumPopulationInput.value}, `;
    } else {
        return "";
    }
}
const maximumPopulationInput = document.getElementById('maximum-population');
function computeMaximumPopulationCode() {
    if (maximumPopulationInput.value && parseInt(maximumPopulationInput.value)) {
        return `maximumPopulation = ${maximumPopulationInput.value}, `;
    } else {
        return "";
    }
}
const firstTurnInput = document.getElementById('first-turn');
function computeFirstTurnCode() {
    if (firstTurnInput.value && parseInt(firstTurnInput.value) > 0) {
        return `earliestTurn = ${firstTurnInput.value}, `
    } else {
        return "";
    }
}
const lastTurnInput = document.getElementById('last-turn');
function computeLastTurnCode() {
    if (lastTurnInput.value && parseInt(lastTurnInput.value)) {
        return `latestTurn = ${lastTurnInput.value}, `
    } else {
        return "";
    }
}

function computeBinarySettings() {
    let output = "";
    if (document.getElementById('computer-only-checkbox').checked) {
        output+="computerOnly = true, ";
    }
    if (document.getElementById('human-only-checkbox').checked) {
        output+="humanOnly = true, ";
    }
    if (document.getElementById('coastal-only-checkbox').checked) {
        output+="onlyBuildCoastal = true, ";
    }
    if (document.getElementById('shipbuild-only-checkbox').checked) {
        output+="onlyBuildShips = true, ";
    }
    if (document.getElementById('hydro-only-checkbox').checked) {
        output+="onlyBuildHydroPlant = true, ";
    }
    if (document.getElementById('override-default-checkbox').checked) {
        output+="overrideDefaultBuildFunction = true, ";
    }
    if (document.getElementById('override-supplementary-checkbox').checked) {
        output+="ignoreSupplementalConditions = true, ";
    }
    return output;
}



// initialize Page
makeForbiddenTribesBoxes();
makeForbiddenMapsBoxes();
const maxNumberTribeRadioUnlimited = document.getElementById("max-number-tribe-radio-unlimited")
maxNumberTribeRadioUnlimited.checked = true;
maxNumberTribeRadioUnlimited.addEventListener('change', (e) => updateHeadings());
const maxNumberTribeRadioLimited = document.getElementById("max-number-tribe-radio-limited")
maxNumberTribeRadioLimited.addEventListener('change', (e) => updateHeadings());
const maxNumberGlobalRadioUnlimited = document.getElementById("max-number-global-radio-unlimited")
maxNumberGlobalRadioUnlimited.checked = true;
maxNumberGlobalRadioUnlimited.addEventListener('change', (e) => updateHeadings());
const maxNumberGlobalRadioLimited = document.getElementById("max-number-global-radio-limited")
maxNumberGlobalRadioLimited.addEventListener('change', (e) => updateHeadings());
updateHeadings();
const sampleListValueArray = []
//listGeneratorDiv.appendChild(makeListCreatorForm({optionsArrays:[unitList,improvementList,wonderList],optionsArraysTitles:["units","improvements","wonders"],listStorageArray:sampleListValueArray,code:"newList"}))
makeListCatalogueBox();
if (testObject) {
    document.getElementById('h3-warning').hidden = false;
}
