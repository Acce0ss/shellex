import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Image {
            anchors.horizontalCenter:  parent.horizontalCenter
            source: "/usr/share/icons/hicolor/86x86/apps/harbour-shellex.png"
        }
        Label {
            id: label
            anchors.horizontalCenter:  parent.horizontalCenter
            text: "ShellEx"
        }
    }



    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: app.focusQuickCommand();
        }
    }
}


