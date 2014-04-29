import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

QtObject {
    id: root

    function createStoredCommand(name, content, type, runnerType) {

        var newObj = {name: name, content: content,
            createdOn: new Date().getTime()/1000, lastRunOn: new Date().getTime()/1000,
            type: type, runIn: runnerType};

        var existing = sheller.getCommandNamed(newObj.name);

        if(existing === null)
        {

            var created = commandsStore.addCommand(newObj);

            if(created !== null)
            {
                created.startProcess();

                openOutputPage(created);

            }
            else
            {
                console.log("Error in database insertion.");
            }
        }
        else
        {
            console.log("Command already in db. running it..")
            existing.startProcess();

            openOutputPage(existing);
        }
    }

    function openOutputPage(command)
    {
        if(command.runIn === ShellCommand.InsideApp)
        {
            if(pageStack.currentPage.objectName == 'EditCommandPage')
            {
                pageStack.replace(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                                  {command: command},
                                  PageStackAction.Animated);
            }
            else
            {
                pageStack.push(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                               {command: command});
            }
        }
    }
}
