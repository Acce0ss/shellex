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
    Q_PROPERTY(Executor runIn READ runIn WRITE setRunIn NOTIFY runInChanged)

    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(QDateTime createdOn READ createdOn NOTIFY createdOnChanged)
    Q_PROPERTY(QDateTime lastRunOn READ lastRunOn NOTIFY lastRunOnChanged)
    Q_PROPERTY(int runCount READ runCount NOTIFY runCountChanged)
    Q_PROPERTY(bool updatedOnThisStart READ updatedOnThisStart WRITE setUpdatedOnThisStart NOTIFY updatedOnThisStartChanged)

    Q_PROPERTY(bool hasParameters READ hasParameters)
    Q_PROPERTY(CommandOutputModel* output READ output NOTIFY outputChanged)

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(bool isStarting READ isStarting NOTIFY isStartingChanged)

    Q_ENUMS(CommandType)
    Q_ENUMS(Executor)

public:
    enum CommandType {Script, SingleLiner};
    enum Executor {Fingerterm, InsideApp, UseSavedRunner};

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

    Executor runIn() const;
    void setRunIn(Executor type);

    QString content() const;
    void setContent(QString content);

    bool isInDatabase();
    void setIsInDatabase(bool inDb);

    unsigned int id();
    void setId(unsigned int id);

    unsigned int runCount() const;
    void setRunCount(unsigned int count);

    bool hasParameters() const;

    CommandOutputModel* output();

    bool isRunning() const;
    bool isStarting() const;

    bool updatedOnThisStart() const;
    void setUpdatedOnThisStart(bool updated);

    QProcess* getProcess();
    void initProcess();

    Q_INVOKABLE QJsonObject getAsJSONObject();
    Q_INVOKABLE void startDetached(Executor runner,  QJsonArray parameters = QJsonArray());
    Q_INVOKABLE void sendInputLine(QString input);
    Q_INVOKABLE void sendInputChar(QString input);

signals:

    void nameChanged();
    void typeChanged();
    void contentChanged();

    void isRunningChanged();
    void isStartingChanged();
    void runInChanged();
    void updatedOnThisStartChanged();

    void lastRunOnChanged();
    void createdOnChanged();
    void runCountChanged();

    void outputChanged();
public slots:

    bool startProcess(Executor runner,  QJsonArray parameters = QJsonArray());

    void stopProcess();

private slots:
    void processFinished(int code, QProcess::ExitStatus status);

    void readStandardOutput();
    void readStandardError();

private:

    QString createRunnerScript();

    static bool SubjectAndTestValid(const ShellCommand *subject, const ShellCommand *test);

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

    Executor m_run_in;

    bool m_updated_on_this_start;

    int m_lines_max;

    QString m_script_path;
};

#endif // SHELLCOMMAND_H
