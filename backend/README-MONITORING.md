# 📊 Monitoring ShowMe Backend

## Services de monitoring inclus

### 🎯 **Grafana** (Port 3001)
- **URL**: http://localhost:3001
- **Login**: admin / admin123
- **Usage**: Dashboards visuels, alertes

### 📈 **Prometheus** (Port 9090)
- **URL**: http://localhost:9090
- **Usage**: Collecte des métriques système et application

### 📋 **Loki + Promtail**
- **Usage**: Collecte et agrégation des logs
- **Intégré**: Dans Grafana comme source de données

### 🖥️ **Node Exporter** (Port 9100)
- **Usage**: Métriques système (CPU, RAM, Disque, Réseau)

## 🚀 Démarrage rapide

```bash
# Démarrer tout l'environnement avec monitoring
make dev

# Ou démarrer uniquement le monitoring
make monitoring

# Vérifier la santé des services
make health
```

## 📊 Métriques surveillées

### **Système**
- CPU Usage (%)
- Memory Usage (%)
- Disk Usage (%)
- Network Traffic

### **Application**
- Status UP/DOWN
- Response Times
- Error Rates
- Database Connections

### **Logs**
- Application Logs
- Error Logs
- Request Logs

## 🔧 Configuration des alertes

Les dashboards Grafana sont pré-configurés avec des seuils d'alerte :

- **CPU > 90%** → Rouge
- **Memory > 90%** → Rouge
- **Disk > 90%** → Rouge
- **Application DOWN** → Rouge

## 📱 Accès mobile

Grafana est responsive et accessible depuis mobile pour surveiller votre infrastructure à distance.