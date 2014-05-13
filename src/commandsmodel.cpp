#include <QDebug>
#include <QtAlgorithms>

#include "commandsmodel.h"
#include "shellcommand.h"

CommandsModel::CommandsModel(QObject *parent) :
    QAbstractListModel(parent), m_commands(), m_not_searchresult()
    ,m_searchString(""), m_sort_type(ByNewestCreated)
{
}

int CommandsModel::rowCount(const QModelIndex &parent) const
{
    return m_commands.count();
}

QVariant CommandsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
    {
        qDebug() << "Tried to access data item " << index.row() << "which is not valid!";
        return QVariant();
    }

    if(role == Qt::DisplayRole)
    {
        ShellCommand* temp = m_commands.at(index.row());

        if(temp != NULL)
        {
          //  qDebug() << "ShellCommand at " << index.row() << "is " << temp;
            return QVariant::fromValue(temp);
        }


    }

    qDebug() << "Errors occurred with ShellCommand at " << index.row();
    return QVariant();
}

int CommandsModel::sortType()
{
    return (int)m_sort_type;
}

void CommandsModel::removeAt(int index)
{
    if(index >= 0 && index < m_commands.length())
    {
        ShellCommand* temp = m_commands.at(index);
        beginRemoveRows(QModelIndex(), index, index);
        m_commands.removeAt(index);
        endRemoveRows();
        if(temp != NULL)
        {
            temp->deleteLater();
        }
    }
}

void CommandsModel::insert(ShellCommand *toInsert)
{
    if(toInsert != NULL)
    {
        int index = 0;
        if(!m_commands.empty())
        {
            QList<ShellCommand*>::iterator i = getInsertPosition(m_sort_type, toInsert, m_commands);

            index = (i - m_commands.begin());

        }

        beginInsertRows(QModelIndex(), index, index);
        m_commands.insert(index, toInsert);
        endInsertRows();
    }
}

int CommandsModel::indexOf(ShellCommand *searchObj)
{
    if(searchObj != NULL)
    {
        return m_commands.indexOf(searchObj);
    }
    return -1;
}

ShellCommand *CommandsModel::at(int index)
{
    if(index >= 0 && index < m_commands.count())
    {
        return m_commands.at(index);
    }
}

void CommandsModel::reInsertCommand(ShellCommand *toUpdate)
{
    if(toUpdate != NULL)
    {
        int index = m_commands.indexOf(toUpdate);

        QList<ShellCommand*> temp = m_commands;

        temp.removeAt(index);

        QList<ShellCommand*>::iterator i = getInsertPosition(m_sort_type, toUpdate, temp);

        int hypotheticPosition = (i - temp.begin());

        //  qDebug() << index << " != " << hypotheticPosition << " = " << (index != hypotheticPosition);

        if(index != (hypotheticPosition))
        {
            beginResetModel();
            if(index >= 0 && index < m_commands.count())
            {
                m_commands.removeAt(index);

                this->insertOnReset(toUpdate);
            }
            endResetModel();
        }
    }
}


void CommandsModel::sortCommands(CommandsModel::SortType type, bool isResort)
{
    QList<ShellCommand*> temp;

    bool newValue = m_sort_type != type;

    if(newValue)
    {
        m_sort_type = type;
        emit sortTypeChanged();
    }

    if(newValue || isResort)
    {

        beginResetModel();

        switch(type)
        {
        case ByLeastRuns:
            this->sortCommandsByLeastRuns();
            break;
        case ByMostRuns:
            this->sortCommandsByMostRuns();
            break;
        case ByName:
            this->sortCommandsByName();
            break;
        case ByNameReverse:
            this->sortCommandsByReverseName();
            break;
        case ByNewestCreated:
            this->sortCommandsByNewestCreated();
            break;
        case ByOldestCreated:
            this->sortCommandsByOldestCreated();
            break;
        case ByNewestRun:
            this->sortCommandsByNewestRun();
            break;
        case ByOldestRun:
            this->sortCommandsByOldestRun();
            break;
        case ByIsRunning:
            this->sortCommandsByIsRunning();
            break;
        default:
            break;
        }


        //hackish way to sort, not optimal.. later change to Sorting proxy model!
        //remove all items and push them into a temp list.
//        while(!m_commands.empty())
//        {
//        //    beginRemoveRows(QModelIndex(), 0, 0);
//            temp.push_front(m_commands.at(0));
//            m_commands.pop_front();
//          //  endRemoveRows();
//        }

//        //insert them back to the model in the new sorting order
//        for(int i = 0; i < temp.count(); ++i)
//        {
//            this->insertOnReset(temp.at(i));

//        }

        endResetModel();

    }

}

//Don't use anymore, use reloadCommandsModel instead
void CommandsModel::reSortCommands()
{
    this->sortCommands(m_sort_type, true);
}

void CommandsModel::applySearchStringFiltering()
{

    //first check if some of the hidden commands need to be shown again
    QList<ShellCommand*> to_readd;

    for(int i = 0; i < m_not_searchresult.count(); i++)
    {

        if(m_not_searchresult.at(i) != NULL)
        {
            if(m_not_searchresult.at(i)->name().toLower().contains(m_searchString.toLower()))
            {
                to_readd.push_back(m_not_searchresult.at(i));
            }
        }
    }

    //qDebug() << "At start, size of m_commands is " << m_commands.count() << ", of to_readd is " << to_readd.count()
//             << " and of m_not_searchresult is " << m_not_searchresult.count();

    //find commands that do not fit into the search anymore
    for(int i = 0; i < m_commands.count(); i++)
    {
        if(m_commands.at(i) != NULL)
        {
            //qDebug() << "Checking command at index " << i << ", " << m_commands.at(i)->name();
            if(!m_commands.at(i)->name().toLower().contains(m_searchString.toLower()))
            {
                //qDebug() << m_searchString << " is not in " << m_commands.at(i)->name();
                m_not_searchresult.push_back(m_commands.at(i));
            }
        }

    }

    beginResetModel();

    //readd the previous, now hit commands and remove from not being a search result
    for(int i = 0; i < to_readd.count(); i++)
    {
        if(to_readd.at(i) != NULL)
        {
            int index = m_not_searchresult.indexOf(to_readd.at(i));
            if(index >= 0 && index < m_not_searchresult.count())
            {
                m_not_searchresult.removeAt(index);
                this->insertOnReset(to_readd.at(i));
            }
        }
    }

    //remove commands that do not contain search term from the model, but keep them in another list
    for(int i = 0; i < m_not_searchresult.count(); i++)
    {

        if(m_not_searchresult.at(i) != NULL)
        {
            int index = m_commands.indexOf(m_not_searchresult.at(i));

            if(index >= 0 && index < m_commands.count())
            {
                //qDebug() << "removing " << m_not_searchresult.at(i)->name() << " at " << index
                //         << ", which in m_commands is " << m_commands.at(index)->name();
                m_commands.removeAt(index);
            }
        }
    }

    endResetModel();

    //qDebug() << "in the end, size of m_commands is " << m_commands.count() << ", of to_readd is " << to_readd.count()
    //         << " and of m_not_searchresult is " << m_not_searchresult.count();

}

void CommandsModel::insertOnReset(ShellCommand *toInsert)
{
    if(toInsert != NULL)
    {
        int index = 0;
        if(!m_commands.empty())
        {
            QList<ShellCommand*>::iterator i = getInsertPosition(m_sort_type, toInsert, m_commands);

            index = (i - m_commands.begin());

        }

        m_commands.insert(index, toInsert);
    }
}


void CommandsModel::sortCommandsByName()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::alphabeticallyBefore);
}

void CommandsModel::sortCommandsByReverseName()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::alphabeticallyAfter);
}

void CommandsModel::sortCommandsByNewestRun()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::moreRecentThan);
}

void CommandsModel::sortCommandsByOldestRun()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::lessRecentThan);
}

void CommandsModel::sortCommandsByMostRuns()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::moreUsedThan);
}

void CommandsModel::sortCommandsByLeastRuns()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::lessUsedThan);
}

void CommandsModel::sortCommandsByNewestCreated()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::newerThan);
}

void CommandsModel::sortCommandsByOldestCreated()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::olderThan);
}

void CommandsModel::sortCommandsByIsRunning()
{
    QList<ShellCommand*> sortedCommands;

    for(int i=0; i<m_commands.length(); i++)
    {
        if(m_commands.at(i) != NULL)
        {
            if(m_commands.at(i)->isRunning())
            {
                sortedCommands.push_front(m_commands.at(i));
            }
            else
            {
                sortedCommands.push_back(m_commands.at(i));
            }
        }
        else
        {
            qDebug() << "Error: Null in the model";
        }
    }

    m_commands.clear();
    m_commands = sortedCommands;

}



QList<ShellCommand*>::iterator CommandsModel::binaryBound(QList<ShellCommand*>::iterator start,
                                                          QList<ShellCommand*>::iterator end)
{
    QList<ShellCommand*>::iterator i;
    for(i = start; i != end; ++i)
    {
        if(!(*i)->isRunning())
        {
            return i;
        }
    }
}

QList<ShellCommand*>::iterator CommandsModel::getInsertPosition(CommandsModel::SortType type, ShellCommand* command
                                                                , QList<ShellCommand*> &searchlist )
{
    switch(type)
    {
    case ByLeastRuns:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::lessUsedThan);
        break;
    case ByMostRuns:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::moreUsedThan);
        break;
    case ByName:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::alphabeticallyBefore);
        break;
    case ByNameReverse:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::alphabeticallyAfter);
        break;
    case ByNewestCreated:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::newerThan);
        break;
    case ByOldestCreated:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::olderThan);
        break;
    case ByNewestRun:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::moreRecentThan);
        break;
    case ByOldestRun:
        return qUpperBound(searchlist.begin(), searchlist.end(), command, ShellCommand::lessRecentThan);
        break;
    case ByIsRunning:
        return binaryBound(searchlist.begin(), searchlist.end());
        break;
    default:
        break;
    }
}

void CommandsModel::reloadCommandsModel(QString searchString)
{
    m_searchString = searchString;
    this->applySearchStringFiltering();
}

ShellCommand *CommandsModel::findCommandByName(QString command)
{
    for(int i = 0; i < rowCount(); i++)
    {

        ShellCommand* temp = m_commands.at(i);
        if(temp != NULL)
        {
            if(temp->name() == command)
            {
                return temp;
            }
        }
    }

    return NULL;
}

ShellCommand *CommandsModel::findCommandById(unsigned int id)
{

    for(int i = 0; i < rowCount(); i++)
    {

        ShellCommand* temp = m_commands.at(i);
        if(temp != NULL)
        {
            if(temp->id() == id)
            {
                return temp;
            }
        }
    }

    return NULL;

}
