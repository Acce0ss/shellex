#include <QProcess>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QVariantList>
#include <QJsonArray>
#include <QJsonObject>
#include <QtAlgorithms>

#include "shellexecutor.h"
#include "shellcommand.h"

ShellExecutor::ShellExecutor(QObject *parent) :
    QObject(parent), m_commands(), m_searchString(""), m_sort_type(ByNewestCreated)
{
}


void ShellExecutor::quickExecute(QJsonObject commandObject, Executor runner)
{

    ShellCommand* comm = findCommandByName(commandObject["name"].toString());

    if( comm == NULL)
    {
        comm = new ShellCommand(this, commandObject["name"].toString(),
                (ShellCommand::CommandType)(int)commandObject["type"].toDouble(),
                commandObject["content"].toString());
        m_commands.push_back(comm);
        emit commandsModelChanged();
    }
    comm->startProcess(runner);

}

void ShellExecutor::executeByIndex(int index, ShellExecutor::Executor runner)
{
    if(index >= 0 && index < m_commands.length())
    {
        m_commands.at(index)->startProcess(runner);
    }
}

void ShellExecutor::executeDetached(QString commands, ShellExecutor::Executor runner)
{

}

void ShellExecutor::executeDetachedByIndex(int index, ShellExecutor::Executor runner)
{

}

QList<QObject*> ShellExecutor::commandsModel()
{
    QList<QObject*> temp;
    for(int i = 0; i < m_commands.length(); i ++)
    {
        if(m_commands.at(i)->name().contains(m_searchString, Qt::CaseInsensitive))
        {
            temp.push_back(dynamic_cast<QObject*>(m_commands.at(i)));
        }
    }

    return temp;
}

int ShellExecutor::sortType()
{
    return (int)m_sort_type;
}

void ShellExecutor::sortCommands(ShellExecutor::SortType type, bool isResort)
{
    if(m_sort_type != type || isResort)
    {
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
    }
    if(m_sort_type != type)
    {
        m_sort_type = type;
        emit sortTypeChanged();
    }
}

void ShellExecutor::reSortCommands()
{
    this->sortCommands(m_sort_type, true);
}

//legacy method
void ShellExecutor::initFromArray(QVariantList array)
{
    for(int i = 0; i < array.length(); i++)
    {
        QString name = array.at(i).toString();
        m_commands.push_back(

                        new ShellCommand(
                            this, name, ShellCommand::SingleLiner, name
                            )
                    );
    }
    emit commandsModelChanged();
}

void ShellExecutor::initFromJSON(QString jsonString)
{

}

void ShellExecutor::initFromJSONArray(QJsonArray jsonArray)
{
    for(int i=0; i< jsonArray.size(); i++)
    {
        m_commands.push_back(ShellCommand::fromJSONObject(jsonArray.at(i).toObject()));
    }
    this->sortCommandsByNewestCreated();
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByName()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::alphabeticallyBefore);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByReverseName()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::alphabeticallyAfter);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByNewestRun()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::moreRecentThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByOldestRun()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::lessRecentThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByMostRuns()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::moreUsedThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByLeastRuns()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::lessUsedThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByNewestCreated()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::newerThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByOldestCreated()
{
    qSort(m_commands.begin(), m_commands.end(), ShellCommand::olderThan);
    emit commandsModelChanged();
}

void ShellExecutor::sortCommandsByIsRunning()
{
    QList<ShellCommand*> sortedCommands;

    for(int i=0; i<m_commands.length(); i++)
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

    m_commands.clear();
    m_commands = sortedCommands;

    emit commandsModelChanged();
}

QList<ShellCommand*>::iterator ShellExecutor::binaryBound(QList<ShellCommand*>::iterator start,
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

QList<ShellCommand*>::iterator ShellExecutor::getInsertPosition(ShellExecutor::SortType type, ShellCommand* command)
{
    switch(type)
    {
    case ByLeastRuns:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::lessUsedThan);
        break;
    case ByMostRuns:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::moreUsedThan);
        break;
    case ByName:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::alphabeticallyBefore);
        break;
    case ByNameReverse:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::alphabeticallyAfter);
        break;
    case ByNewestCreated:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::newerThan);
        break;
    case ByOldestCreated:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::olderThan);
        break;
    case ByNewestRun:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::moreRecentThan);
        break;
    case ByOldestRun:
        return qUpperBound(m_commands.begin(), m_commands.end(), command, ShellCommand::lessRecentThan);
        break;
    case ByIsRunning:
        return binaryBound(m_commands.begin(), m_commands.end());
        break;
    default:
        break;
    }
}

QVariantList ShellExecutor::getCommandNames()
{
    QList<QVariant> list;
    for(int i=0; i < m_commands.length(); i++)
    {
        list.push_back(m_commands.at(i)->name());
    }

    return list;
}

QJsonArray ShellExecutor::getCommandsAsJSON()
{
    QJsonArray tempArray;
    for(int i=0; i < m_commands.length(); i++)
    {
        tempArray.push_back(QJsonValue(m_commands.at(i)->getAsJSONObject()));
    }

    return tempArray;
}

QObject *ShellExecutor::getCommandNamed(QString name)
{
    return dynamic_cast<QObject*>(findCommandByName(name));
}

void ShellExecutor::removeCommandByIndex(int i)
{
    if(i >= 0 && i < m_commands.length())
    {
        ShellCommand* temp = m_commands.at(i);
        m_commands.removeAt(i);
        temp->deleteLater();
        emit commandsModelChanged();
    }
}

void ShellExecutor::removeCommandById(unsigned int id)
{
    ShellCommand* temp = this->findCommandById(id);
    if(temp != NULL)
    {
        m_commands.removeAt(m_commands.indexOf(temp));
        temp->deleteLater();
        emit commandsModelChanged();
    }
}

QObject* ShellExecutor::addCommandFromJSON(QJsonObject object)
{
    ShellCommand* temp = ShellCommand::fromJSONObject(object);
    QList<ShellCommand*>::iterator i = getInsertPosition(m_sort_type, temp);
    m_commands.insert(i, temp);
    emit commandsModelChanged();

    return dynamic_cast<QObject*>(temp);
}

void ShellExecutor::reloadCommandsModel(QString searchString)
{
    m_searchString = searchString;
    emit commandsModelChanged();
}

ShellCommand *ShellExecutor::findCommandByName(QString command)
{
    for(int i = 0; i < m_commands.length(); i++)
    {

        if(m_commands.at(i)->name() == command)
        {
            return m_commands.at(i);
        }
    }

    return NULL;
}

ShellCommand *ShellExecutor::findCommandById(unsigned int id)
{

    for(int i = 0; i < m_commands.length(); i++)
    {

        if(m_commands.at(i)->id() == id)
        {
            return m_commands.at(i);
        }
    }

    return NULL;

}
