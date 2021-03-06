#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>

#include <QProcess>
#include <QFile>
#include <QDir>
#include <QChar>
#include <QStandardPaths>
#include <QDebug>
#include <QQmlEngine>

#include "shellcommand.h"
#include "commandoutputmodel.h"

ShellCommand::ShellCommand(QObject *parent) :
  QObject(parent), m_name(""), m_type(SingleLiner), m_content(""), m_process(new QProcess(this)),
  m_is_running(false), m_created_on(QDateTime::currentDateTime()), m_last_run_on(),
  m_is_in_database(false), m_id(UINT_MAX), m_run_count(0), m_output(new CommandOutputModel(this)),
  m_run_in(InsideApp), m_updated_on_this_start(false), m_lines_max(10), m_script_path("")
{

  //Explicitly promise to take care of the object, and deny js garbage collector from destroying it
  QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

  connect(m_process, static_cast<void (QProcess::*)(int,QProcess::ExitStatus)>(&QProcess::finished), this, &ShellCommand::processFinished);
  connect(m_process, &QProcess::readyReadStandardOutput, this, &ShellCommand::readStandardOutput);
  connect(m_process, &QProcess::readyReadStandardError, this, &ShellCommand::readStandardError);

  m_process->setProcessChannelMode(QProcess::SeparateChannels);
}


ShellCommand::ShellCommand(QObject *parent, QString name, CommandType type, QString content) :
  QObject(parent), m_name(name), m_type(type), m_content(content), m_process(new QProcess(this)),
  m_is_running(false), m_created_on(QDateTime::currentDateTime()), m_last_run_on(),
  m_is_in_database(false), m_id(UINT_MAX), m_run_count(0), m_output(new CommandOutputModel(this)),
  m_run_in(InsideApp), m_updated_on_this_start(false), m_lines_max(10), m_script_path("")
{
  //Explicitly promise to take care of the object, and deny js garbage collector from destroying it
  QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

  connect(m_process, static_cast<void (QProcess::*)(int,QProcess::ExitStatus)>(&QProcess::finished), this, &ShellCommand::processFinished);
  connect(m_process, &QProcess::readyReadStandardOutput, this, &ShellCommand::readStandardOutput);
  connect(m_process, &QProcess::readyReadStandardError, this, &ShellCommand::readStandardError);

  m_process->setProcessChannelMode(QProcess::SeparateChannels);
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

    if(m_content != "")
    {
      this->createRunnerScript();
    }

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
    m_script_path = this->createRunnerScript();
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

bool ShellCommand::hasParameters() const
{
  QJsonDocument doc = QJsonDocument::fromJson(m_content.toLocal8Bit());
  QJsonObject obj = doc.object();
  if(obj.contains("parameters"))
  {
    QJsonArray parameters = obj["parameters"].toArray();
    if(parameters.count() >= 1)
    {
      return true;
    }
  }

  return false;
}

ShellCommand::Executor ShellCommand::runIn() const
{
  return m_run_in;
}

void ShellCommand::setRunIn(ShellCommand::Executor type)
{
  if(m_run_in != type)
  {
    m_run_in = type;
    emit runInChanged();
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

  qDebug() << "Error in isRunning: ShellCommand " << m_name << " tried to operate on null m_process";
  return false;
}

bool ShellCommand::isStarting() const
{
  if(m_process != NULL)
  {
    return ((m_process->state() == QProcess::Starting));
  }
  qDebug() << "Error in isStarting: ShellCommand " << m_name << " tried to operate on null m_process";
  return false;
}

bool ShellCommand::updatedOnThisStart() const
{
  return m_updated_on_this_start;
}

void ShellCommand::setUpdatedOnThisStart(bool updated)
{
  if(m_updated_on_this_start != updated)
  {
    m_updated_on_this_start = updated;
    emit updatedOnThisStartChanged();
  }
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
  tempObj.insert("linesMax", QJsonValue(m_output->linesMax()));

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

  switch(m_run_in)
  {
    case Fingerterm:
      tempObj.insert("runIn", QJsonValue(QString("Fingerterm")));
      break;
    case InsideApp:
      tempObj.insert("runIn", QJsonValue(QString("InsideApp")));
      break;
    default:
      break;
  }

  return tempObj;
}

void ShellCommand::startDetached(Executor runner, QJsonArray parameters)
{

  if(m_script_path == "")
  {
    qDebug() << "Error, runner script not created and tried to run";
    return;
  }

  Executor run_in;

  if(runner == UseSavedRunner)
  {
    run_in = m_run_in;
  }
  else
  {
    run_in = runner;
  }

  QString processName = "fingerterm";
  QString processParam = "-e";

  if(run_in == InsideApp)
  {
    processName = "bash";
    processParam = "-c";
  }

  QString run_this = m_script_path;
  for(unsigned int i = 0; i < parameters.count(); i++)
  {
    run_this.append(" ").append(parameters.at(i).toString());
  }

  qDebug() << "Running detached bash -c " << run_this;

  QProcess::startDetached(processName, QStringList() << processParam << run_this);

  m_last_run_on = QDateTime::currentDateTime();
  m_run_count++;

  emit lastRunOnChanged();
  emit runCountChanged();
}

void ShellCommand::sendInputLine(QString input)
{
  if(m_process != NULL)
  {
    m_process->write(input.append('\n').toLocal8Bit());
  }
}

void ShellCommand::sendInputChar(QString input)
{
  if(m_process != NULL)
  {
    m_process->write(input.toLocal8Bit());
  }
}

bool ShellCommand::startProcess(Executor runner, QJsonArray parameters)
{
  if(m_process == NULL)
  {
    qDebug() << "Fatal error, m_process was NULL";
    m_process = new QProcess(this);
  }
  else if(m_process->state() != QProcess::NotRunning)
  {
    return false;
  }

  if(m_script_path == "")
  {
    qDebug() << "Error, runner script not created and tried to run";
    return false;
  }

  Executor run_in;

  if(runner == UseSavedRunner)
  {
    run_in = m_run_in;
  }
  else
  {
    run_in = runner;
  }

  QString processName = "fingerterm";
  QString processParam = "-e";

  if(run_in == InsideApp)
  {
    processName = "bash";
    processParam = "-c";
  }

  if(m_output != NULL)
  {
    m_output->append(trUtf8("Command %1 starting...").arg(m_name));
  }
  else
  {
    m_output = new CommandOutputModel(this);
    m_output->append(trUtf8("Command %1 starting...").arg(m_name));
  }

  if(m_process != NULL)
  {

    QString run_this = m_script_path;
    for(unsigned int i = 0; i < parameters.count(); i++)
    {
      run_this.append(" ").append(parameters.at(i).toString());
    }

    qDebug() << "Running bash -c " << run_this;

    m_process->start(processName, QStringList() << processParam << run_this );

    m_last_run_on = QDateTime::currentDateTime();
    m_run_count++;
    m_updated_on_this_start = false;

    emit updatedOnThisStartChanged();
    emit lastRunOnChanged();
    emit runCountChanged();

    emit isStartingChanged();
    emit isRunningChanged();

    return true;
  }
  else
  {
    qDebug() << "Fatal error: m_process NULL when trying to start the command " << m_name;
  }
  return false;
}

void ShellCommand::stopProcess()
{
  if(m_process != NULL)
  {
    if(this->isRunning())
    {
      Q_PID pid = m_process->pid();

      QStringList params;
      params << "-P";
      params << QString::number(pid);

      qDebug() << params;

      QProcess::startDetached("pkill", params );

      m_process->close();
    }
  }
  else
  {
    qDebug() << "Error: ShellCommand " << m_name << " tried to operate on null m_process";
  }
}

void ShellCommand::processFinished(int code, QProcess::ExitStatus status)
{

  if(m_output != NULL)
  {
    m_output->append(trUtf8("Program returned exit code %1").arg(QString::number(code)));
  }
  else
  {
    qDebug() << "Error in processFinished: ShellCommand " << m_name << " tried to operate on null m_output";
  }

  emit isRunningChanged();
}

void ShellCommand::readStandardOutput()
{
  qDebug() << "process " << m_name << " has new std output: ";

  if(m_process != NULL)
  {

    QByteArray newOutput = m_process->readAllStandardOutput();
    qDebug() << newOutput;
    QStringList outputs = QString(newOutput)
        .split(QRegExp("[\r\n]"),QString::SkipEmptyParts);

    if(m_output != NULL)
    {

      m_output->append(outputs);

    }
    else
    {
      qDebug() << "Error in readStandardOutput: ShellCommand " << m_name << " tried to operate on null m_output";
    }

  }
  else
  {
    qDebug() << "Error in readStandardOutput: ShellCommand " << m_name << " tried to operate on null m_process";
  }
}

void ShellCommand::readStandardError()
{
  qDebug() << "process " << m_name << " has new err output: ";
  if(m_process != NULL)
  {
    QByteArray newOutput = m_process->readAllStandardOutput();
    qDebug() << newOutput;
    QStringList outputs = QString(newOutput)
        .split(QRegExp("[\r\n]"),QString::SkipEmptyParts);
    if(m_output != NULL)
    {

      m_output->append(outputs);

    }
    else
    {
      qDebug() << "Error in readStandardError: ShellCommand " << m_name << " tried to operate on null m_output";
    }
  }
  else
  {
    qDebug() << "Error in readStandardError: ShellCommand " << m_name << " tried to operate on null m_process";
  }
}

QString ShellCommand::createRunnerScript()
{
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

  //qDebug() << file;

  QFile tempScript(file);

  if(!tempScript.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
  {
    qDebug("File for temp script could not be opened.");
    file = "";;
  }
  if(!tempScript.setPermissions(QFile::ReadOwner|QFile::WriteOwner|QFile::ExeOwner))
  {

    qDebug("File permission for temp script could not be set.");
    file = "";

  }
  else
  {

    QTextStream out(&tempScript);

    QJsonDocument contentDoc = QJsonDocument::fromJson(m_content.toLocal8Bit());

    qDebug() << "Making script from JSON: " << m_content;

    if(contentDoc.object().contains("script"))
    {
      QString scriptContent = contentDoc.object()["script"].toString();

      if(!scriptContent.startsWith("#!/"))
      {
        //add default bash hint for shell, unless user has written something else
        out << "#!/bin/bash\n";
      }
      out << scriptContent;
    }
    else
    {
      qDebug() << "Error! command " << m_name << " has no content!";
    }

    tempScript.close();
  }

  return file;
}

bool ShellCommand::SubjectAndTestValid(const ShellCommand *subject, const ShellCommand *test)
{
  if(subject != NULL && test != NULL)
  {
    return true;
  }
  else
  {
    qDebug() << "Error when comparing for sort: tried to operate on null subject or test";
  }
  return false;
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

  if(toBeCreated != NULL)
  {

    toBeCreated->setName(JSONObject["name"].toString());
    toBeCreated->setContent(JSONObject["content"].toString());
    toBeCreated->setCreatedOn(QDateTime::fromTime_t((int)JSONObject["createdOn"].toDouble()));
    toBeCreated->setLastRunOn(QDateTime::fromTime_t((int)JSONObject["lastRunOn"].toDouble()));
    toBeCreated->setRunCount((int)JSONObject["runCount"].toDouble());
    toBeCreated->output()->setLinesMax((int)JSONObject["linesMax"].toDouble());

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

    if(JSONObject["runIn"].toString() == "Fingerterm")
    {
      toBeCreated->setRunIn(Fingerterm);
    }
    else if(JSONObject["runIn"].toString() == "InsideApp")
    {
      toBeCreated->setRunIn(InsideApp);
    }

  }
  else
  {
    qDebug() << "Error creating command from " << JSONObject.toVariantMap() << " : operator 'new' returned NULL.";
  }
  //qDebug() << "Creating command: name: " << toBeCreated->name()
  //         << " type: " << toBeCreated->type() << " createdOn: " << toBeCreated->createdOn()
  //         << " lastRunOn: " << toBeCreated->lastRunOn() << " content: " << toBeCreated->content()
  //         << " isInDatabase: " << toBeCreated->isInDatabase() << " id: " << toBeCreated->id();

  return toBeCreated;

}

bool ShellCommand::newerThan(const ShellCommand *subject, const ShellCommand *test)
{

  if(SubjectAndTestValid(subject, test))
  {
    //subject was created later than test
    return subject->createdOn() > test->createdOn();
  }
  return false;
}

bool ShellCommand::olderThan(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    //subject was created earlier than test
    return subject->createdOn() < test->createdOn();
  }
  return false;
}

bool ShellCommand::lessUsedThan(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    return subject->runCount() < test->runCount();
  }
  return false;
}

bool ShellCommand::moreUsedThan(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    return subject->runCount() > test->runCount();
  }
  return false;
}

bool ShellCommand::moreRecentThan(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    //qDebug() << "command " << subject->name() << ", " << subject->lastRunOn().toTime_t() <<  ", is more recent than "
    //         << test->name() << ", " << test->lastRunOn().toTime_t()
    //         <<  ", is " << (subject->lastRunOn() > test->lastRunOn());
    //subject has been run more recently (later) than test
    return subject->lastRunOn() > test->lastRunOn();
  }
  return false;
}

bool ShellCommand::lessRecentThan(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    //subject has been run before (earlier) than test
    return subject->lastRunOn() < test->lastRunOn();
  }
  return false;
}

bool ShellCommand::alphabeticallyBefore(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    //case insensitive, is subject before test alphabetically
    return subject->name().toLower() < test->name().toLower();
  }
  return false;
}

bool ShellCommand::alphabeticallyAfter(const ShellCommand *subject, const ShellCommand *test)
{
  if(SubjectAndTestValid(subject, test))
  {
    //case insensitive, is subject after test alphabetically
    return subject->name().toLower() > test->name().toLower();
  }
  return false;
}

ShellCommand::~ShellCommand()
{
  //    if(m_process != NULL)
  //    {
  //        m_process->close();
  //        m_process->deleteLater();
  //    }

  //    if(m_output != NULL)
  //    {
  //        m_output->deleteLater();
  //    }
  qDebug() << "ShellCommand " << m_name << " dying";

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
