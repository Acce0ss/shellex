#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>

#include <QProcess>
#include <QFile>
#include <QDir>
#include <QChar>
#include <QStandardPaths>
#include <QDebug>

#include "shellcommand.h"
#include "commandoutputmodel.h"

ShellCommand::ShellCommand(QObject *parent) :
    QObject(parent), m_name(""), m_type(SingleLiner), m_content(""), m_process(NULL),
    m_is_running(false), m_created_on(QDateTime::currentDateTime()), m_last_run_on(),
    m_is_in_database(false), m_id(UINT_MAX), m_run_count(0), m_output(new CommandOutputModel(this))
{
}


ShellCommand::ShellCommand(QObject *parent, QString name, CommandType type, QString content) :
    QObject(parent), m_name(name), m_type(type), m_content(content), m_process(NULL),
    m_is_running(false), m_created_on(QDateTime::currentDateTime()), m_last_run_on(),
    m_is_in_database(false), m_id(UINT_MAX), m_run_count(0), m_output(new CommandOutputModel(this))
{
}

QString ShellCommand::name() const
{
    return this->m_name;
}

void ShellCommand::setName(QString name)
{
    if(m_name != name)
    {
        m_name = name;
        emit nameChanged();
    }
}

ShellCommand::CommandType ShellCommand::type() const
{
    return this->m_type;
}

void ShellCommand::setType(ShellCommand::CommandType type)
{

    if(type != m_type)
    {
        m_type = type;
        emit typeChanged();
    }
}

QString ShellCommand::content() const
{
    return m_content;

}

void ShellCommand::setContent(QString content)
{
    if(content != m_content)
    {
        m_content = content;
        emit contentChanged();
    }
}

bool ShellCommand::isInDatabase()
{
    return m_is_in_database;
}

void ShellCommand::setIsInDatabase(bool inDb)
{
    m_is_in_database = inDb;
}

unsigned int ShellCommand::id()
{
    return m_id;
}

void ShellCommand::setId(unsigned int id)
{
    m_id = id;
}

unsigned int ShellCommand::runCount() const
{
    return m_run_count;
}

void ShellCommand::setRunCount(unsigned int count)
{
    if(m_run_count != count)
    {
        m_run_count = count;
        emit runCountChanged();
    }
}

CommandOutputModel *ShellCommand::output()
{
    return m_output;
}

bool ShellCommand::isRunning() const
{
    if(m_process != NULL)
    {
        return ((m_process->state() == QProcess::Starting)||(m_process->state() == QProcess::Running));
    }
    return false;
}

bool ShellCommand::isStarting() const
{
    if(m_process != NULL)
    {
        return ((m_process->state() == QProcess::Starting));
    }
    return false;
}

QProcess *ShellCommand::getProcess()
{
    return m_process;
}

QJsonObject ShellCommand::getAsJSONObject()
{
    QJsonObject tempObj;

    tempObj.insert("name", QJsonValue(m_name));
    tempObj.insert("content", QJsonValue(m_content));
    tempObj.insert("createdOn", QJsonValue((int)m_created_on.toTime_t()));
    tempObj.insert("lastRunOn", QJsonValue((int)m_last_run_on.toTime_t()));
    tempObj.insert("isInDatabase", QJsonValue(m_is_in_database));
    tempObj.insert("runCount", QJsonValue((int)m_run_count));
    tempObj.insert("id", QJsonValue((int)m_id));

    switch(m_type)
    {
    case SingleLiner:
        tempObj.insert("type", QJsonValue(QString("SingleLiner")));
        break;
    case Script:
        tempObj.insert("type", QJsonValue(QString("Script")));
        break;
    default:
        break;
    }

    return tempObj;
}

bool ShellCommand::startProcess(int executorType)
{
    if(m_process == NULL)
    {
        m_process = new QProcess(this);
    }
    else if(m_process->state() != QProcess::NotRunning)
    {
        return false;
    }
    else
    {
        m_process->deleteLater();
        m_process = new QProcess(this);
    }

    QString dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    if(!QDir(dir).exists())
    {
        qDebug() << "Creating .local/share storage location...";
        QDir().mkpath(dir);
    }

    QString file("");

    QString tempName = m_name;
    file = dir.append(tempName.replace(QRegExp(QString::fromUtf8("[-`~!@#$%^&*()_ —+=|:;<>«»,.?/{}\'\"\\\[\\\]\\\\]")), QString("_"))
                      .prepend("/").append(".sh"));

    switch(m_type)
    {
    case SingleLiner:
        break;
    case Script:
        break;
    default:
        break;
    }

    qDebug() << file;

    QFile tempScript(file);

    if(!tempScript.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
    {
        return false;
    }
    if(!tempScript.setPermissions(QFile::ReadOwner|QFile::WriteOwner|QFile::ExeOwner))
    {

      qDebug("File permission for temp script could not be set.");

    }

    QTextStream out(&tempScript);

    out << "#!/bin/bash\n";
    out << m_content;


    tempScript.close();

    QString processName = "fingerterm";
    QString processParam = "-e";

    if(executorType == (int)ShellExecutor::Script)
    {
        processName = file;
        file = "";
        processParam = "";
    }

    m_output->append(trUtf8("Command %1 starting...").arg(m_name));

    connect(m_process, static_cast<void (QProcess::*)(int,QProcess::ExitStatus)>(&QProcess::finished), this, &ShellCommand::processFinished);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &ShellCommand::readStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &ShellCommand::readStandardError);

    m_process->start(processName, QStringList() << processParam << file);


    m_last_run_on = QDateTime::currentDateTime();
    m_run_count++;

    emit lastRunOnChanged();
    emit runCountChanged();

    emit isStartingChanged();
    emit isRunningChanged();

    return true;
}

void ShellCommand::stopProcess()
{
    if(m_process != NULL)
    {
        Q_PID pid = m_process->pid();

        QStringList params;
        params << "-P";
        params << QString::number(pid);
        QProcess killer;
        killer.start("pkill", params );
        killer.waitForFinished();

        m_process->close();
    }
}

void ShellCommand::processFinished(int code, QProcess::ExitStatus status)
{

    m_output->append(trUtf8("Program returned exit code %1").arg(QString::number(code)));

    emit isRunningChanged();

    m_process->deleteLater();
    m_process = NULL;
}

void ShellCommand::readStandardOutput()
{
    QStringList outputs = QString(m_process->readAllStandardOutput())
            .split(QRegExp("[\r\n]"),QString::SkipEmptyParts);
    for(int i=0; i < outputs.length(); i++)
    {
        m_output->append(outputs.at(i));
    }
}

void ShellCommand::readStandardError()
{
    QStringList outputs = QString(m_process->readAllStandardError())
            .split(QRegExp("[\r\n]"),QString::SkipEmptyParts);
    for(int i=0; i < outputs.length(); i++)
    {
        m_output->append(outputs.at(i));
    }
}


ShellCommand *ShellCommand::fromJSONString(QString JSON)
{
    QJsonDocument doc = QJsonDocument::fromJson(JSON.toLocal8Bit());
    QJsonObject obj = doc.object();

    return ShellCommand::fromJSONObject(obj);
}

ShellCommand *ShellCommand::fromJSONObject(QJsonObject JSONObject)
{
    ShellCommand * toBeCreated = new ShellCommand();

    toBeCreated->setName(JSONObject["name"].toString());
    toBeCreated->setContent(JSONObject["content"].toString());
    toBeCreated->setCreatedOn(QDateTime::fromTime_t((int)JSONObject["createdOn"].toDouble()));
    toBeCreated->setLastRunOn(QDateTime::fromTime_t((int)JSONObject["lastRunOn"].toDouble()));
    toBeCreated->setRunCount((int)JSONObject["runCount"].toDouble());

    if(JSONObject.contains("isInDatabase"))
    {
        toBeCreated->setIsInDatabase((((int)JSONObject["isInDatabase"].toDouble() != 0)));

    }
    else
    {
        toBeCreated->setIsInDatabase(false);
    }

    if(JSONObject.contains("id"))
    {
        toBeCreated->setId((int)JSONObject["id"].toDouble());
    }
    else
    {
        toBeCreated->setId(UINT_MAX);
    }

    if(JSONObject["type"].toString() == "SingleLiner")
    {
        toBeCreated->setType(SingleLiner);
    }
    else if(JSONObject["type"].toString() == "Script")
    {
        toBeCreated->setType(Script);
    }

    qDebug() << "Creating command: name: " << toBeCreated->name()
             << " type: " << toBeCreated->type() << " createdOn: " << toBeCreated->createdOn()
             << " lastRunOn: " << toBeCreated->lastRunOn() << " content: " << toBeCreated->content()
             << " isInDatabase: " << toBeCreated->isInDatabase() << " id: " << toBeCreated->id();

    return toBeCreated;
}

bool ShellCommand::newerThan(const ShellCommand *subject, const ShellCommand *test)
{
    //subject was created later than test
    return subject->createdOn() > test->createdOn();
}

bool ShellCommand::olderThan(const ShellCommand *subject, const ShellCommand *test)
{
    //subject was created earlier than test
    return subject->createdOn() < test->createdOn();
}

bool ShellCommand::lessUsedThan(const ShellCommand *subject, const ShellCommand *test)
{
    return subject->runCount() < test->runCount();
}

bool ShellCommand::moreUsedThan(const ShellCommand *subject, const ShellCommand *test)
{
    return subject->runCount() > test->runCount();
}

bool ShellCommand::moreRecentThan(const ShellCommand *subject, const ShellCommand *test)
{
    //subject has been run more recently (later) than test
    return subject->lastRunOn() > test->lastRunOn();
}

bool ShellCommand::lessRecentThan(const ShellCommand *subject, const ShellCommand *test)
{
    //subject has been run before (earlier) than test
    return subject->lastRunOn() < test->lastRunOn();
}

bool ShellCommand::alphabeticallyBefore(const ShellCommand *subject, const ShellCommand *test)
{
    //case insensitive, is subject before test alphabetically
    return subject->name().toLower() < test->name().toLower();
}

bool ShellCommand::alphabeticallyAfter(const ShellCommand *subject, const ShellCommand *test)
{
    //case insensitive, is subject after test alphabetically
    return subject->name().toLower() > test->name().toLower();
}

ShellCommand::~ShellCommand()
{
    if(m_process != NULL)
    {
        m_process->close();
        m_process->waitForFinished();
        m_process->deleteLater();
    }

    m_output->deleteLater();

}

QDateTime ShellCommand::createdOn() const
{
    return m_created_on;
}

void ShellCommand::setCreatedOn(QDateTime time)
{
    if(m_created_on != time)
    {
        m_created_on = time;
        emit createdOnChanged();
    }
}

QDateTime ShellCommand::lastRunOn() const
{
    return m_last_run_on;
}

void ShellCommand::setLastRunOn(QDateTime time)
{
    if(m_last_run_on != time)
    {
        m_last_run_on = time;
        emit lastRunOnChanged();
    }
}
