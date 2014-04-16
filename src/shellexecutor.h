#ifndef SHELLEXECUTOR_H
#define SHELLEXECUTOR_H

#include <QObject>
#include <QList>
#include <QVariantList>
#include <QJsonArray>
#include <QJsonObject>

class ShellCommand;

class ShellExecutor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QList<QObject *> commandsModel READ commandsModel NOTIFY commandsModelChanged)
    Q_PROPERTY(int sortType READ sortType NOTIFY sortTypeChanged)

    Q_ENUMS(Executor)
    Q_ENUMS(SortType)

public:
    explicit ShellExecutor(QObject *parent = 0);

    enum Executor {Fingerterm, Script};
    enum SortType {ByName, ByNameReverse, ByNewestRun, ByOldestRun, ByMostRuns,
                   ByLeastRuns, ByNewestCreated, ByOldestCreated, ByIsRunning};

    Q_INVOKABLE void quickExecute(QJsonObject commandObject, Executor runner);
    Q_INVOKABLE void executeByIndex(int index, Executor runner);
    Q_INVOKABLE void executeDetached(QString commands, Executor runner);
    Q_INVOKABLE void executeDetachedByIndex(int index, Executor runner);

    QList<QObject *> commandsModel();

    int sortType();

signals:

    void commandsModelChanged();
    void sortTypeChanged();
public slots:

    void sortCommands(SortType type, bool isResort);
    void reSortCommands();

    void initFromArray(QVariantList array);
    void initFromJSON(QString jsonString);
    void initFromJSONArray(QJsonArray jsonArray);

    QVariantList getCommandNames();
    QJsonArray getCommandsAsJSON();

    QObject* getCommandNamed(QString name);

    void removeCommandByIndex(int i);
    void removeCommandById(unsigned int id);

    //returns pointer to the object newly created and added
    QObject *addCommandFromJSON(QJsonObject object);

    void reloadCommandsModel(QString searchString);
private:
    ShellCommand* findCommandByName(QString command);
    ShellCommand* findCommandById(unsigned int id);

    void sortCommandsByName();
    void sortCommandsByReverseName();

    void sortCommandsByNewestRun();
    void sortCommandsByOldestRun();

    void sortCommandsByMostRuns();
    void sortCommandsByLeastRuns();

    void sortCommandsByNewestCreated();
    void sortCommandsByOldestCreated();

    void sortCommandsByIsRunning();

    QList<ShellCommand*>::iterator binaryBound(QList<ShellCommand*>::iterator start,
                                               QList<ShellCommand*>::iterator end);

    QList<ShellCommand*>::iterator getInsertPosition(SortType type, ShellCommand *command);


    QList<ShellCommand*> m_commands;

    QString m_searchString;

    SortType m_sort_type;
};

#endif // SHELLEXECUTOR_H
