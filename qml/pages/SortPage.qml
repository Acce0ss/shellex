import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Page {

    id: root

    property string sortName: qsTr("Newest first")

    allowedOrientations: Orientation.All

    SilicaListView {

            width: parent.width

            anchors.fill: parent

            header: PageHeader {
                title: qsTr("Sort by")
            }

            model: sortingsModel

            delegate: Component {
                ListItem {
                    id: sortOption
                    contentHeight: Theme.itemSizeSmall

                    Label {
                        anchors.centerIn: parent
                        color: sortOption.highlighted ? Theme.highlightColor : Theme.primaryColor
                        text: sortingsModel.names[index]
                    }

                    onClicked: {
                        shell.sortCommands(type, false);
                        root.sortName = sortingsModel.names[index];
                        pageStack.pop();
                    }
                }
            }
    }

    ListModel {
        id: sortingsModel

        property var names: [qsTr("Newest"),
                             qsTr("Oldest"),
                             qsTr("Most recently used"),
                             qsTr("Least recently used"),
                             qsTr("Alphabetically"),
                             qsTr("Aplhabetically reversed"),
                             qsTr("Most used"),
                             qsTr("Least used"),
                             qsTr("Running first")]
        ListElement {
            type: ShellExecutor.ByNewestCreated
        }
        ListElement {
            type: ShellExecutor.ByOldestCreated
        }
        ListElement {
            type: ShellExecutor.ByNewestRun
        }
        ListElement {
            type: ShellExecutor.ByOldestRun
        }
        ListElement {
            type: ShellExecutor.ByName
        }
        ListElement {
            type: ShellExecutor.ByNameReverse
        }
        ListElement {
            type: ShellExecutor.ByMostRuns
        }
        ListElement {
            type: ShellExecutor.ByLeastRuns
        }
        ListElement {
            type: ShellExecutor.ByIsRunning
        }
    }

}
