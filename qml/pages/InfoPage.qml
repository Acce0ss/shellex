import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: root

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: aboutContent.height

        VerticalScrollDecorator {}

        Column {

            id: aboutContent

            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
            }

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
