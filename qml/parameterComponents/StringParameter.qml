import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {

  id: root

  //function to initialize input, detailsObject must of the format
  //spesified in the respective *ParameterSetup.qml
  //Need to be provided by this name!
  function initializeParameter(detailsObject) {

    root.text = detailsObject.defaultValue;
    root.label = detailsObject.description;
    root.placeholderText = detailsObject.description;

  }
  property string parameterValue: text  //Need to be provided by this name!
  property bool acceptableInputs: acceptableInput

  width: parent.width

  validator: RegExpValidator {
    regExp: /^\S+.*$/ //not empty
  }

}
