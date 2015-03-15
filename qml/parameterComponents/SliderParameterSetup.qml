import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width
  spacing: Theme.paddingMedium

  property string pluginDescription: qsTr("Parameter for numeric values, using a slider")

  property var detailsObject: {"minValue": minValueInput.text,
                               "maxValue": maxValueInput.text,
                               "defaultValue": defaultValueInput.text,
                               "description": parameterDescriptionInput.text,
                               "stepSize": stepSizeInput.text}

  function initializeSetup(obj)
  {
    if(obj.hasOwnProperty("minValue"))
    {
       minValueInput.text = obj.minValue;
    }

    if(obj.hasOwnProperty("maxValue"))
    {
       maxValueInput.text = obj.maxValue;
    }

    if(obj.hasOwnProperty("defaultValue"))
    {
       defaultValueInput.text = obj.defaultValue;
    }

    if(obj.hasOwnProperty("stepSize"))
    {
       stepSizeInput.text = obj.stepSize;
    }

    if(obj.hasOwnProperty("description"))
    {
      parameterDescriptionInput.text = obj.description;
    }
  }

  TextField {

    id: minValueInput

    width: parent.width

    validator: DoubleValidator {
      id: setupValueValidator
    }
    label: qsTr("Minimum value")
    placeholderText: label

    inputMethodHints: Qt.ImhDigitsOnly
  }
  TextField {

    id: maxValueInput

    width: parent.width

    validator: setupValueValidator
    label: qsTr("Maximum value")
    placeholderText: label
    inputMethodHints: Qt.ImhDigitsOnly
  }
  TextField {

    id: stepSizeInput

    width: parent.width

    validator: setupValueValidator
    label: qsTr("Step size")
    placeholderText: label
    inputMethodHints: Qt.ImhDigitsOnly
  }
  TextField {

    id: defaultValueInput

    width: parent.width

    validator: setupValueValidator
    label: qsTr("Default value")
    placeholderText: label
    inputMethodHints: Qt.ImhDigitsOnly
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
