import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

QtObject {
    id: root

    function createStoredCommand(name, content, type, runnerType, linesMax) {

        var existing = sheller.getCommandNamed(name);

        if(existing === null)
        {
            var runnerName = "Fingerterm";
            switch(runnerType)
            {
            case ShellCommand.Fingerterm:
                break;
            case ShellCommand.Script:
                runnerName = "Script";
                break;
            default:
                console.log("Error");
            }

            var newObj = {name: name, content: content,
                createdOn: new Date().getTime()/1000, lastRunOn: new Date().getTime()/1000,
                type: type, runIn: runnerName, linesMax: linesMax};

            var created = commandsStore.addCommand(newObj);

            if(created !== null)
            {

                created.startProcess(runnerType);

                openOutputPage(created, runnerType);

            }
            else
            {
                console.log("Error in database insertion.");
            }
        }
        else
        {
            console.log("Command already in db. running it..")

            existing.startProcess(runnerType);

            openOutputPage(existing, runnerType);
        }
    }

    function openOutputPage(command, runner)
    {
        var run_in = runner;
        if(runner === ShellCommand.UseSavedRunner)
        {
            run_in = command.runIn;
        }

        //if ran in Fingerterm, no need for outputpage
        if(run_in === ShellCommand.InsideApp)
        {
            if(pageStack.currentPage.objectName == 'EditCommandPage')
            {
                pageStack.replace(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                                  {command: command, storageReference: commandsStore},
                                  PageStackAction.Animated);
            }
            else
            {
                pageStack.push(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                               {command: command, storageReference: commandsStore});
            }
        }

    }

    //Thanks to rob at stackoverflow.com
    function timeSince(date) {

        var seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000);
        var intervalType;

        var interval = Math.floor(seconds / 31536000);
        if (interval >= 1) {
            intervalType = qsTr("year");
        } else {
            interval = Math.floor(seconds / 2592000);
            if (interval >= 1) {
                intervalType = qsTr("month");
            } else {
                interval = Math.floor(seconds / 86400);
                if (interval >= 1) {
                    intervalType = qsTr("day");
                } else {
                    interval = Math.floor(seconds / 3600);
                    if (interval >= 1) {
                        intervalType = qsTr("hour");
                    } else {
                        interval = Math.floor(seconds / 60);
                        if (interval >= 1) {
                            intervalType = qsTr("minute");
                        } else {
                            intervalType = "second";
                        }
                    }
                }
            }
        }

        var returnString = "";

        if(intervalType !== "second")
        {
            if (interval > 1) {

                intervalType = qsTr("%1s", "make time into plural").arg(intervalType);

            }
            returnString = qsTr("%1 %2 ago").arg(interval).arg(intervalType);
        }
        else
        {
            returnString = qsTr("just now");
        }

        return returnString;
    }
}
