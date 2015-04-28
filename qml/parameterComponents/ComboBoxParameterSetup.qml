import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width
  spacing: Theme.paddingMedium

  property string pluginDescription: qsTr("Parameter for set of options. Preferable to use less than 6 values.")

  property bool acceptableInputs: valuesInput.acceptableInput &&
                                  parameterDescriptionInput.acceptableInput

  property var detailsObject: {"defaultValueIndex": defaultValueInput.value,
                               "values": valuesInput.text,
                               "description": parameterDescriptionInput.text}

  function initializeSetup(obj)
  {
    if(obj.hasOwnProperty("values"))
    {
      valuesInput.text = obj.values;
    }

    if(obj.hasOwnProperty("defaultValueIndex"))
    {
      defaultValueInput.value = obj.defaultValueIndex;
    }

    if(obj.hasOwnProperty("description"))
    {
      parameterDescriptionInput.text = obj.description;
    }
  }

  TextField {

    id: valuesInput

    width: parent.width

    validator: notEmptyValidator

    label: qsTr("Values in format value1; value2 etc.")
    placeholderText: label

    onTextChanged: {
      var tmp = text;
      if(tmp.charAt(tmp.length-1) === ';')
      {
        tmp = tmp.substring(0,tmp.length-1);
      }

      var values = tmp.split(";");

      defaultValueInput.maximumValue = values.length;
    }
  }

  Slider {

    id: defaultValueInput

    width: parent.width

    minimumValue: 1
    maximumValue: 1
    stepSize: 1
    value: 1

    label: qsTr("index of default value")
    valueText: value
  }

  TextField {

    id: parameterDescriptionInput

    width: parent.width

    validator: RegExpValidator {
      id: notEmptyValidator
      regExp: /^\S+.*$/
    }

    label: qsTr("Parameter description")
    placeholderText: label
  }


}
