#ifndef COMMANDNAMEVALIDATOR_H
#define COMMANDNAMEVALIDATOR_H

#include <QValidator>

class ShellCommand;
class CommandsModel;

class CommandNameValidator : public QValidator
{
    Q_OBJECT

    Q_PROPERTY(ShellCommand* command READ command WRITE setCommand NOTIFY commandChanged)
    Q_PROPERTY(CommandsModel* model READ model WRITE setModel NOTIFY modelChanged)

  public:
    CommandNameValidator();

    ShellCommand* command() const;

    void setCommand(ShellCommand* command);

    CommandsModel* model() const;

    void setModel(CommandsModel* model);

    State validate(QString & input, int & pos) const;

  signals:
    void commandChanged();
    void modelChanged();

  private:

    ShellCommand* m_command;
    CommandsModel* m_model;
};

#endif // COMMANDNAMEVALIDATOR_H
