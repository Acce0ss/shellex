import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

import "pages"
import "cover"

ApplicationWindow
{
    id: app

    function focusQuickCommand() {
        if(!Qt.application.active)
        {
            app.activate();
            pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"), {shell: sheller});
            pageStack.currentPage.focusInput();
        }
        app.deactivate()
    }

    Routine {
        id: routineLib
    }

    ShellExecutor {
        id: sheller
    }

    CommandsStore {
        id: commandsStore
        shell: sheller
    }

    MainPage {
        id: mainPage
        shell: sheller
    }

    initialPage: mainPage
    cover: Component {
        CoverPage {

        }
    }
}


