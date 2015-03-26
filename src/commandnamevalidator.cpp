#include "commandnamevalidator.h"
#include "commandsmodel.h"
#include "shellcommand.h"

CommandNameValidator::CommandNameValidator() : m_model(NULL), m_command(NULL)
{
}

ShellCommand *CommandNameValidator::command
() const
{
  return m_command;
}

void CommandNameValidator::setCommand(ShellCommand *command)
{
  if(m_command != command)
  {
    m_command = command;
    emit commandChanged();
  }
}

CommandsModel *CommandNameValidator::model() const
{
  return m_model;
}

void CommandNameValidator::setModel(CommandsModel *model)
{
  if(m_model != model)
  {
    m_model = model;
    emit modelChanged();
  }
}

QValidator::State CommandNameValidator::validate(QString &input, int &pos) const
{
  if(m_model != NULL) //if model has not been given, just accept
  {
    ShellCommand* temp = m_model->findCommandByName(input);

    if(temp != NULL) //if command by that name was found
    {
      if(m_command != NULL) // if reference (editing) command has been set
      {
        if(m_command != temp) // if the command is not the command found
        {
          return Intermediate; // the input equals to some other command, reject
        }
      }
      else
      {
        return Intermediate; // the input refers to any command, reject
      }
    }
  }

  return Acceptable; // genuinely unique name or the old name

}
