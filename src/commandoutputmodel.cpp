#include <QChar>

#include "commandoutputmodel.h"

CommandOutputModel::CommandOutputModel(QObject *parent) : QAbstractListModel(parent),
    m_data(), m_lines_max(100)
{
}

void CommandOutputModel::append(QString outputString)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_data.append(outputString);
    endInsertRows();

    removeFromFront();

}

void CommandOutputModel::removeFromFront()
{
    if(rowCount() > m_lines_max)
    {
        int rowsToRemove = m_data.length()-m_lines_max;

        for(int i = 0; i < rowsToRemove; i++)
        {
            beginRemoveRows(QModelIndex(), 0, 0);
            m_data.pop_front();
            endRemoveRows();
        }

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
    if (index.row() < 0 || index.row() >= m_data.count())
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

void CommandOutputModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_data.size()-1);
    m_data.clear();
    endRemoveRows();
}
