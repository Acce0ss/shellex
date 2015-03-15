import QtQuick 2.0
import Sailfish.Silica 1.0

Slider {

  id: root

  //function to initialize input, detailsObject must of the format
  //spesified in the respective *ParameterSetup.qml
  //Need to be provided by this name!
  function initializeParameter (detailsObject) {
    root.minimumValue = detailsObject.minValue;
    root.maximumValue = detailsObject.maxValue;
    root.stepSize = detailsObject.stepSize;
    root.value = detailsObject.defaultValue;
    root.label = detailsObject.description;
  }
  property real parameterValue: value  //Need to be provided by this name!

  valueText: value
  width: parent.width


}
