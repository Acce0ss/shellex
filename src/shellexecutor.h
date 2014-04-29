#ifndef SHELLEXECUTOR_H
#define SHELLEXECUTOR_H

#include <QObject>
#include <QList>
#include <QVariantList>
#include <QJsonArray>
#include <QJsonObject>

#include "commandsmodel.h"

class ShellCommand;

class ShellExecutor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(CommandsModel* commandsModel READ commandsModel NOTIFY commandsModelChanged)
    Q_PROPERTY(bool fingertermInstalled READ fingertermInstalled NOTIFY fingertermInstalledChanged)

public:
    explicit ShellExecutor(QObject *parent = 0);

    ~ShellExecutor();

    Q_INVOKABLE void stopAllCommands();

    CommandsModel *commandsModel();

    bool fingertermInstalled();

signals:

    void commandsModelChanged();
    void fingertermInstalledChanged();
public slots:

    void initFromArray(QVariantList array);
    void initFromJSON(QString jsonString);
    void initFromJSONArray(QJsonArray jsonArray);

    QVariantList getCommandNames();
    QJsonArray getCommandsAsJSON();

    QObject* getCommandNamed(QString name);

    void removeCommandByIndex(int i);
    void removeCommandById(unsigned int id);

    void updateCommandById(unsigned int id);

    //returns pointer to the object newly created and added
    QObject *addCommandFromJSON(QJsonObject object);

    void reloadCommandsModel(QString searchString);

    void sortCommands(int type, bool isResort);
    void reSortCommands();



private slots:
    void refreshCommandsModel();
private:
    CommandsModel* m_commands;

    bool m_fingerterm_installed;
};

#endif // SHELLEXECUTOR_H
