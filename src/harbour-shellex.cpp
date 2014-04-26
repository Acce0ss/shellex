
#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QQuickView>
#include <QGuiApplication>

#include "shellexecutor.h"
#include "shellcommand.h"
#include "commandoutputmodel.h"
#include "commandsmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);

    app->setOrganizationName("harbour-shellex");
    app->setApplicationName("harbour-shellex");

    qmlRegisterType<CommandOutputModel>("harbour.shellex", 1, 0, "CommandOutputModel");
    qmlRegisterType<CommandsModel>("harbour.shellex", 1, 0, "CommandsModel");
    qmlRegisterType<ShellExecutor>("harbour.shellex", 1, 0, "ShellExecutor");
    qmlRegisterType<ShellCommand>("harbour.shellex", 1, 0, "ShellCommand");

    QScopedPointer<QQuickView> viewer(SailfishApp::createView());

    viewer->setSource(SailfishApp::pathTo("qml/harbour-shellex.qml"));

    viewer->show();

    return app->exec();
}

