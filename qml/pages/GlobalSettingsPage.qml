import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Dialog {
    id: root

    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: content.height

        Column {
            id: content

            width: parent.width

            DialogHeader {
                title: qsTr("Settings")
                acceptText: qsTr("Save")
            }

            TextSwitch {
                id: resetHints
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Reset gesture hints on save")
            }

            SectionHeader {
                text: qsTr("About")
            }
            Column {
                width: parent.width-2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    width: parent.width - parent.spacing*2
                    anchors.horizontalCenter: parent.horizontalCenter

                    wrapMode: Text.WordWrap

                    text: qsTr("Author: %1").arg("Asser Lähdemäki")
                }

                Separator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - parent.spacing*2
                    color: Theme.secondaryHighlightColor
                }
                Label {
                    width: parent.width - parent.spacing*2
                    anchors.horizontalCenter: parent.horizontalCenter

                    wrapMode: Text.WordWrap

                    text: qsTr("Version: %1").arg("0.2")
                }

                Label {
                    width: parent.width - parent.spacing*2
                    anchors.horizontalCenter: parent.horizontalCenter

                    wrapMode: Text.WordWrap

                    text: qsTr("License: %1").arg("BSD 3-clause")
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: qsTr("Source at Github")
                    onClicked: {
                        Qt.openUrlExternally("https://github.com/Acce0ss/shellex")
                    }
                }
            }
        }

    }

    onAccepted: {
        if(resetHints.checked)
        {
            globalSettings.timesHintShown = 0;
        }

        globalSettings.storeSettings();
    }
}
