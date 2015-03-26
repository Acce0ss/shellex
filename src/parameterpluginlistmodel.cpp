#include <QStandardPaths>
#include <QDir>
#include <QDebug>

#include "parameterpluginlistmodel.h"

ParameterPluginListModel::ParameterPluginListModel(QObject *parent) :
  QAbstractListModel(parent), m_base_dir()
{
  QStringList filters;
  filters << "*?Parameter.qml";
  m_base_dir.setNameFilters(filters);

  m_base_dir.setFilter(QDir::Files | QDir::Readable);
  setBaseDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/parameterComponents/");
}

QString ParameterPluginListModel::baseDir() const
{
  return m_base_dir.absolutePath();
}

void ParameterPluginListModel::setBaseDir(QString dir)
{
  if(dir != m_base_dir.absolutePath())
  {
    QString temp_old = m_base_dir.absolutePath();
    m_base_dir.setPath(dir);
    if(!m_base_dir.exists())
    {
      qDebug() << "Directory " << dir << " does not exist! Cannot set";
      m_base_dir.setPath(temp_old);
    }
    else
    {
      emit baseDirChanged();
      emit modelChanged();
    }
  }
}

ParameterPluginListModel::~ParameterPluginListModel()
{

}

int ParameterPluginListModel::rowCount(const QModelIndex &parent) const
{
  return m_base_dir.count();
}

QVariant ParameterPluginListModel::data(const QModelIndex &index, int role) const
{

  if (!index.isValid())
  {
      qDebug() << "Tried to access data item " << index.row() << "which is not valid!";
      return QVariant();
  }

  QStringList files = m_base_dir.entryList();

  if(files.count() < 1)
  {
    return QVariant();
  }

  if(role == Qt::DisplayRole)
  {
    QString fileName = files.at(index.row());

    return QVariant::fromValue(fileName.replace("Parameter.qml", "").replace("_", " "));
  }
  else if(role == ParameterPluginListModel::PathRole)
  {
    return QVariant::fromValue(m_base_dir.absoluteFilePath(files.at(index.row())));
  }
  else if(role == ParameterPluginListModel::SetupPathRole)
  {
    QString fileName = m_base_dir.absoluteFilePath(files.at(index.row()));
    return QVariant::fromValue(fileName.replace(".qml", "Setup.qml"));
  }


  qDebug() << "Errors occurred with filelistmodel at " << index.row();
  return QVariant();
}

QHash<int, QByteArray> ParameterPluginListModel::roleNames() const
{

  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "display";
  roles[ParameterPluginListModel::PathRole] = "path";
  roles[ParameterPluginListModel::SetupPathRole] = "setupPath";
  return roles;

}

