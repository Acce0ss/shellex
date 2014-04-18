#ifndef SHELLCOMMAND_H
#define SHELLCOMMAND_H

#include <QObject>
#include <QJsonObject>
#include <QProcess>
#include <QDateTime>

#include "shellexecutor.h"

class CommandOutputModel;

class ShellCommand : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(CommandType type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(QDateTime createdOn READ createdOn NOTIFY createdOnChanged)
    Q_PROPERTY(QDateTime lastRunOn READ lastRunOn NOTIFY lastRunOnChanged)
    Q_PROPERTY(int runCount READ runCount NOTIFY runCountChanged)

    Q_PROPERTY(CommandOutputModel* output READ output)

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(bool isStarting READ isStarting NOTIFY isStartingChanged)

    Q_ENUMS(CommandType)

public:
    enum CommandType {Script, SingleLiner};

    explicit ShellCommand(QObject *parent = 0);
    explicit ShellCommand(QObject *parent, QString name, CommandType type, QString content);

    ~ShellCommand();

    static ShellCommand* fromJSONString(QString JSON);
    static ShellCommand* fromJSONObject(QJsonObject JSONObject);

    static bool newerThan(const ShellCommand *subject, const ShellCommand *test);
    static bool olderThan(const ShellCommand *subject, const ShellCommand *test);

    static bool lessUsedThan(const ShellCommand *subject, const ShellCommand *test);
    static bool moreUsedThan(const ShellCommand *subject, const ShellCommand *test);

    static bool moreRecentThan(const ShellCommand *subject, const ShellCommand *test);
    static bool lessRecentThan(const ShellCommand *subject, const ShellCommand *test);

    static bool alphabeticallyBefore(const ShellCommand *subject, const ShellCommand *test);
    static bool alphabeticallyAfter(const ShellCommand *subject, const ShellCommand *test);

    QDateTime createdOn() const;
    void setCreatedOn(QDateTime time);

    QDateTime lastRunOn() const;
    void setLastRunOn(QDateTime time);

    QString name() const;
    void setName(QString name);

    CommandType type() const;
    void setType(CommandType type);

    QString content() const;
    void setContent(QString content);

    bool isInDatabase();
    void setIsInDatabase(bool inDb);

    unsigned int id();
    void setId(unsigned int id);

    unsigned int runCount() const;
    void setRunCount(unsigned int count);

    CommandOutputModel* output();

    bool isRunning() const;
    bool isStarting() const;

    QProcess* getProcess();
    void initProcess();

    Q_INVOKABLE QJsonObject getAsJSONObject();

signals:

    void nameChanged();
    void typeChanged();
    void contentChanged();

    void isRunningChanged();
    void isStartingChanged();

    void lastRunOnChanged();
    void createdOnChanged();
    void runCountChanged();
public slots:

    bool startProcess(int executorType);

    void stopProcess();

private slots:
    void processFinished(int code, QProcess::ExitStatus status);

    void readStandardOutput();
    void readStandardError();

private:

    QString m_name;
    CommandType m_type;
    QString m_content;

    QProcess* m_process;

    bool m_is_running;

    QDateTime m_created_on;
    QDateTime m_last_run_on;

    bool m_is_in_database;

    unsigned int m_id;

    unsigned int m_run_count;

    CommandOutputModel* m_output;

};

#endif // SHELLCOMMAND_H
