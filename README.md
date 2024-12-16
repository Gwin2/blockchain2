# Система отслеживания успеваемости в университете на блокчейне

## Обзор
Децентрализованное блокчейн-приложение для отслеживания успеваемости студентов университета, управления курсами и аналитики. Система использует обновляемые прокси-контракты на основе OpenZeppelin для возможности обновления логики без потери данных.

## Архитектура
Система построена с использованием паттерна прокси-контрактов, что позволяет обновлять логику контрактов без потери данных:

### Прокси-контракты
- **UniversityAccessControlProxy**: Прокси для управления доступом
- **CourseManagementProxy**: Прокси для управления курсами
- **GradeManagementProxy**: Прокси для управления оценками
- **ScheduleManagementProxy**: Прокси для управления расписанием
- **StatisticsTrackerProxy**: Прокси для отслеживания статистики

### Логические контракты
- **UniversityAccessControlUpgradeable**: Управление ролями и доступом
- **CourseManagementUpgradeable**: Управление курсами
- **GradeManagementUpgradeable**: Управление оценками
- **ScheduleManagementUpgradeable**: Управление расписанием
- **StatisticsTrackerUpgradeable**: Аналитика и статистика

## Функции

### UniversityAccessControlUpgradeable
- **initialize**: Инициализация контракта и назначение администратора
- **assignRole**: Назначение роли пользователю
- **addUser**: Добавление нового пользователя с ролью
- **getRole**: Получение роли пользователя
- **hasRole**: Проверка наличия роли у пользователя

### CourseManagementUpgradeable
- **initialize**: Инициализация контракта
- **createCourse**: Создание нового курса
- **enrollInCourse**: Запись студента на курс
- **getCourseDetails**: Получение информации о курсе

### GradeManagementUpgradeable
- **initialize**: Инициализация контракта
- **recordGrade**: Запись оценки
- **markAttendance**: Отметка посещаемости
- **getGrades**: Получение оценок
- **getAttendance**: Получение данных о посещаемости

### ScheduleManagementUpgradeable
- **initialize**: Инициализация контракта
- **createSchedule**: Создание расписания
- **getSchedule**: Получение расписания
- **editSchedule**: Редактирование расписания

### StatisticsTrackerUpgradeable
- **initialize**: Инициализация контракта
- **getAverageGrade**: Средняя оценка по курсу
- **getAttendanceRate**: Процент посещаемости
- **getAverageGradeByStudent**: Средняя оценка студента
- **getAttendanceRateByStudent**: Процент посещаемости студента

## Установка и развертывание

### Предварительные требования
1. Node.js (версия 16 или выше)
2. Python 3.9 или выше
3. Hardhat
4. Web3.py

### Установка
1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/yourusername/university-blockchain-tracker.git
   cd university-blockchain-tracker
   ```

2. Установите зависимости Node.js:
   ```bash
   npm install
   ```

3. Установите зависимости Python:
   ```bash
   pip install -r backend/requirements.txt
   ```

### Развертывание контрактов

1. Настройте переменные окружения:
   ```bash
   cp .env.example .env
   # Отредактируйте .env файл, добавив:
   # - INFURA_PROJECT_ID
   # - DEPLOYER_PRIVATE_KEY
   # - ETHERSCAN_API_KEY
   ```

2. Скомпилируйте контракты:
   ```bash
   npx hardhat compile
   ```

3. Разверните прокси-контракты:
   ```bash
   npx hardhat run scripts/deploy_proxies.js --network sepolia
   ```

4. Верифицируйте контракты:
   ```bash
   npx hardhat verify --network sepolia $(cat .deployed/ProxyAdmin.address)
   npx hardhat verify --network sepolia $(cat .deployed/UniversityAccessControlProxy.address)
   # Повторите для остальных прокси-контрактов
   ```

### Тестирование

1. Запустите тесты Solidity:
   ```bash
   npx hardhat test
   ```

2. Запустите тесты Python:
   ```bash
   pytest backend/tests --cov=backend
   ```

## API

### REST API
- **GET /api/courses**: Получение списка курсов
- **POST /api/courses**: Создание нового курса
- **GET /api/courses/{id}**: Получение информации о курсе
- **POST /api/grades**: Запись оценки
- **GET /api/statistics/{course_id}**: Получение статистики по курсу

### Telegram Bot
Бот поддерживает следующие команды:
- `/start`: Начало работы с ботом
- `/courses`: Список доступных курсов
- `/grades`: Просмотр оценок
- `/schedule`: Просмотр расписания
- `/stats`: Просмотр статистики

## Безопасность

### Обновление контрактов
1. Разверните новую версию логического контракта
2. Используйте ProxyAdmin для обновления прокси-контракта
3. Верифицируйте новую имплементацию на Etherscan

### Аудит и тестирование
- Используется Mythril для статического анализа
- Покрытие тестами >95%
- Автоматизированное тестирование в CI/CD

## CI/CD

Проект использует GitHub Actions для автоматизации:
- Компиляция и тестирование контрактов
- Развертывание на тестовую сеть
- Верификация контрактов
- Тестирование Python-бэкенда
- Развертывание в AWS ECS

## Лицензия
MIT