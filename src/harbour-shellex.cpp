
#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QQuickView>
#include <QGuiApplication>
#include <QDir>
#include <QTranslator>

#include "shellexecutor.h"
#include "shellcommand.h"
#include "settings.h"
#include "commandoutputmodel.h"
#include "commandsmodel.h"
#include "parameterpluginlistmodel.h"
#include "commandnamevalidator.h"

int main(int argc, char *argv[])
{
  QGuiApplication *app = SailfishApp::application(argc, argv);

  app->setOrganizationName("harbour-shellex");
  app->setApplicationName("harbour-shellex");

  QDir paramCompos(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/parameterComponents");
  QDir packageParamCompos(SailfishApp::pathTo("qml/parameterComponents/").toLocalFile());
  QStringList files = packageParamCompos.entryList(QStringList() << "*Parameter*.qml",
                                                   QDir::Files | QDir::Readable);

  if(!paramCompos.exists())
  {
    paramCompos.mkpath(paramCompos.absolutePath());
  }

  Settings globalSettings;
  globalSettings.setupConfig("harbour-shellex", "harbour-shellex");

  if(globalSettings.readSetting("resetParameterComponents", true, Settings::Bool).toBool())
  {

    for(int i = 0; i < files.count(); i++)
    {
      QString fileName = paramCompos.absolutePath().append("/").append(files.at(i));
      if(QFile::exists(fileName))
      {
        QFile::remove(fileName);
      }
      QFile::copy(packageParamCompos.absoluteFilePath(files.at(i)),
                  fileName);

    }
  }

  qmlRegisterType<CommandNameValidator>("harbour.shellex", 1, 0, "CommandNameValidator");
  qmlRegisterType<Settings>("harbour.shellex", 1, 0, "Settings");
  qmlRegisterType<CommandOutputModel>("harbour.shellex", 1, 0, "CommandOutputModel");
  qmlRegisterType<CommandsModel>("harbour.shellex", 1, 0, "CommandsModel");
  qmlRegisterType<ParameterPluginListModel>("harbour.shellex", 1, 0, "AvailableParameterModel");
  qmlRegisterType<ShellExecutor>("harbour.shellex", 1, 0, "ShellExecutor");
  qmlRegisterType<ShellCommand>("harbour.shellex", 1, 0, "ShellCommand");

  QTranslator appTranslator;
      appTranslator.load("harbour-shellex-" + QLocale::system().name(),
                         SailfishApp::pathTo("translations").toLocalFile());
      app->installTranslator(&appTranslator);

      qDebug() << SailfishApp::pathTo("translations").toString();

  QScopedPointer<QQuickView> viewer(SailfishApp::createView());

  viewer->setSource(SailfishApp::pathTo("qml/harbour-shellex.qml"));

  viewer->show();

  return app->exec();
}

