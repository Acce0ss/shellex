import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Page {

  id: root

  property ListModel model

  allowedOrientations: Orientation.All

  SilicaListView {

    width: parent.width

    anchors.fill: parent

    header: PageHeader {
      title: qsTr("Add parameter")
    }

    model: AvailableParameterModel { }

    delegate: Component {
      ListItem {
        id: typeOption
        contentHeight: delegateContent.height

        width: parent.width

        Column {
          id: delegateContent

          anchors.horizontalCenter: parent.horizontalCenter

          width: parent.width - 2*Theme.paddingSmall
          spacing: Theme.paddingSmall

          SectionHeader {
            text: model.display
          }
          Label {
            id: pluginDescriptionLabel
            width: parent.width
            wrapMode: Text.WordWrap
            color: typeOption.highlighted ? Theme.highlightColor : Theme.primaryColor
          }
          Loader {
            id: setupDescriptionLoader
            visible: false
            source: model.setupPath
            onLoaded: {
              pluginDescriptionLabel.text = setupDescriptionLoader.item.pluginDescription;
            }
          }
        }

        onClicked: {
          root.model.addParameter({"display":model.display, "setupFilePath":model.setupPath,
                                   "filePath":model.path, "details": {}});
          pageStack.pop();
        }
      }
    }
  }
}
