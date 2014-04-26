#ifndef COMMANDSMODEL_H
#define COMMANDSMODEL_H

#include <QAbstractListModel>

class ShellCommand;

class CommandsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int sortType READ sortType NOTIFY sortTypeChanged)

    Q_ENUMS(SortType)
public:

    enum SortType {ByName, ByNameReverse, ByNewestRun, ByOldestRun, ByMostRuns,
                   ByLeastRuns, ByNewestCreated, ByOldestCreated, ByIsRunning};


    explicit CommandsModel(QObject *parent = 0);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    ShellCommand* findCommandByName(QString command);
    ShellCommand* findCommandById(unsigned int id);

    int sortType();

    void removeAt(int index);
    void insert(ShellCommand* toInsert);
    int indexOf(ShellCommand* searchObj);
    ShellCommand* at(int index);

    void reInsertCommand(ShellCommand* toUpdate);

    void reloadCommandsModel(QString searchString);

signals:

    void commandsModelChanged();
    void sortTypeChanged();

public slots:

    void sortCommands(SortType type, bool isResort);
    void reSortCommands();

private:
    void applySearchStringFiltering();

    QList<ShellCommand*>::iterator binaryBound(QList<ShellCommand*>::iterator start,
                                               QList<ShellCommand*>::iterator end);
    QList<ShellCommand*>::iterator getInsertPosition(SortType type, ShellCommand *command, QList<ShellCommand *> &searchlist);

    void sortCommandsByName();
    void sortCommandsByReverseName();

    void sortCommandsByNewestRun();
    void sortCommandsByOldestRun();

    void sortCommandsByMostRuns();
    void sortCommandsByLeastRuns();

    void sortCommandsByNewestCreated();
    void sortCommandsByOldestCreated();

    void sortCommandsByIsRunning();

    QList<ShellCommand*> m_commands;

    QList<ShellCommand*> m_not_searchresult;

    QString m_searchString;
    SortType m_sort_type;

};

#endif // COMMANDSMODEL_H
