import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

TextField {
    id: root

    property ShellCommand command

    property bool editAccepted: true

    width: parent.width
    validator: IntValidator {
        bottom: 1
        top: 500
    }
    placeholderText: qsTr("Number of lines")
    inputMethodHints: Qt.ImhDigitsOnly
    label: (editAccepted && acceptableInput)
                        ? qsTr("Set number of lines")
                        : qsTr("Press enter to apply")

    onTextChanged: {

        editAccepted = false;
    }

    EnterKey.enabled: acceptableInput

    EnterKey.onClicked: {

        if(editAccepted === false)
        {
            root.command.output.linesMax = root.text;

            var currentCount = root.command.output.count;

            if(currentCount > root.command.output.linesMax)
            {
                var difference = currentCount - root.command.output.linesMax;
                while(difference > 0)
                {
                    root.command.output.removeFromFront();
                    difference--;
                }
            }
            commandsStore.updateCommandLinesMax(root.command);
            editAccepted = true;
        }
    }

    Component.onCompleted: {
        root.text = root.command.output.linesMax;
        root.editAccepted = true;
    }
}
