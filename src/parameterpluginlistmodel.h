#ifndef ParameterPluginListModel_H
#define ParameterPluginListModel_H

#include <QAbstractListModel>
#include <QDir>

class ParameterPluginListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString baseDir READ baseDir WRITE setBaseDir NOTIFY baseDirChanged)

  public:

    enum UiFileRoles { PathRole = Qt::UserRole + 1, SetupPathRole };

    explicit ParameterPluginListModel(QObject *parent = 0);

    QString baseDir() const;
    void setBaseDir(QString dir);

    virtual ~ParameterPluginListModel();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    QHash<int, QByteArray> roleNames() const;

  signals:

    void baseDirChanged();
    void modelChanged();
  public slots:

  private:

    QDir m_base_dir;
};

#endif // ParameterPluginListModel_H
