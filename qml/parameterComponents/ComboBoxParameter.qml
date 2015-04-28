import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox {

  id: root

  //function to initialize input, detailsObject must of the format
  //spesified in the respective *ParameterSetup.qml
  //Need to be provided by this name!
  function initializeParameter(detailsObject) {

    root.label = detailsObject.description;

    var tmp = detailsObject.values;
    if(tmp.charAt(tmp.length-1) === ';')
    {
      tmp = tmp.substring(0,tmp.length-1);
    }

    itemRepeater.model = tmp.split(";");


    defaultIndex = detailsObject.defaultValueIndex;

  }
  property string parameterValue: currentItem.text  //Need to be provided by this name!
  property bool acceptableInputs: true

  width: parent.width

  property int defaultIndex: 1

  menu: ContextMenu {

    Repeater {
      id: itemRepeater

      MenuItem {
        text: modelData
      }

      onModelChanged: {
        root.currentIndex = root.defaultIndex
      }
    }

  }


}
