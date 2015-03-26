#include <QChar>
#include <QDebug>

#include "commandoutputmodel.h"

CommandOutputModel::CommandOutputModel(QObject *parent) : QAbstractListModel(parent),
  m_data(), m_lines_max(100)
{
}

void CommandOutputModel::append(QStringList outputString)
{
  qDebug() << "here, stringlist" << outputString.count();
  if(outputString.count() > 0)
  {
    qDebug() << rowCount()+outputString.count()-1;
    beginInsertRows(QModelIndex(), rowCount(), rowCount()+outputString.count()-1);
    for(int i = 0; i < outputString.count(); i++)
    {
      m_data.append(outputString.at(i));
    }
    endInsertRows();

    this->truncateToMaxLines();

    emit countChanged();
  }
}

void CommandOutputModel::append(QString outputString)
{
  qDebug() << "here, string" << outputString;
  beginInsertRows(QModelIndex(), rowCount(), rowCount());

  m_data.append(outputString);

  endInsertRows();

  this->truncateToMaxLines();

  emit countChanged();
}

void CommandOutputModel::removeFromFront()
{

  if(!m_data.empty())
  {
    beginRemoveRows(QModelIndex(), 0, 0);
    m_data.pop_front();
    endRemoveRows();

    emit countChanged();
  }
}

QString CommandOutputModel::outputString()
{
  return m_data.join(QChar('\n'));
}

int CommandOutputModel::rowCount(const QModelIndex &parent) const
{
  return m_data.count();
}

QVariant CommandOutputModel::data(const QModelIndex &index, int role) const
{
  if (!index.isValid())
  {
    return QVariant();
  }

  if(role == Qt::DisplayRole)
  {
    return m_data.at(index.row());
  }
  return QVariant();
}

int CommandOutputModel::linesMax()
{
  return m_lines_max;
}

void CommandOutputModel::setLinesMax(int lines)
{
  if(m_lines_max != lines)
  {
    m_lines_max = lines;
    emit linesMaxChanged();
  }
}

int CommandOutputModel::count() const
{
  return m_data.count();
}

void CommandOutputModel::clear()
{
  beginResetModel();
  m_data.clear();
  endResetModel();

  emit countChanged();
}

void CommandOutputModel::truncateToMaxLines()
{
  if(m_data.count() > m_lines_max)
  {
    qDebug() << rowCount() << " - " << m_lines_max +1 << " = "<< rowCount() - m_lines_max - 1 << "?";
    int startCount = rowCount();
    beginRemoveRows(QModelIndex(), 0, startCount-m_lines_max-1);
    while(m_data.count() > m_lines_max)
    {
      m_data.pop_front();
    }
    endRemoveRows();
  }
}
