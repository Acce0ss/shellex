import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

QtObject {
    id: root

    function createStoredCommand(name, content, type, runnerType) {

        var newObj = {name: name, content: content,
            createdOn: new Date().getTime()/1000, lastRunOn: new Date().getTime()/1000,
            type: type};

        var created = commandsStore.addCommand(newObj);

        if(created !== null)
        {
            created.startProcess(runnerType);

            if(runnerType === ShellExecutor.Script)
            {
                if(pageStack.currentPage.objectName == 'EditCommandPage')
                {
                    pageStack.replace(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                                      {command: sheller.getCommandNamed(newObj.name)},
                                      PageStackAction.Animated);
                }
                else
                {
                    pageStack.push(Qt.resolvedUrl("pages/ProcessOutputPage.qml"),
                                   {command: sheller.getCommandNamed(newObj.name)});
                }
            }
        }
        else
        {
            console.log("errorz")
        }
    }
}
