# LowViewer

## Общая информация
Программа просмотра файла почтового лога через web форму, с возможностью поиска по адресату 

## Запуск программы (локально)

1. выполните команду, для получения данного локального ее запуска:
```shell
git clone https://github.com/savadevel/LogViewer.git
```

2. перейди в каталог с программой
```shell
cd ./LogViewer
```

3. запустите программу (запускается в docker, при этом создаются три сервиса: db, app, nginx)
```shell
docker compose up
```

## Работа с программой

1. После запуска программы, она доступна по адресу http://127.0.0.1:8080/

![image](https://github.com/savadevel/LogViewer/assets/69199994/cbf64fd1-030e-42a4-97e0-87e474d33d69)

2. Задайте в поле "Адрес получателя" адрес эл. почты, по которым требуется вывести почтовый лог и нажмите кнопку "Искать"
![image](https://github.com/savadevel/LogViewer/assets/69199994/4cf31d6f-c964-46b8-a39a-010591c4e060)

3. Отображаемый результат ограничить сотней записей (по-умолчанию), если количество найденных строк превышает указанный лимит, выдаваться соответствующее сообщение
![image](https://github.com/savadevel/LogViewer/assets/69199994/c509db60-d86c-4f47-9d00-3e0d887e55b9)

4. Если задан "Адрес получателя" не в формате адреса эл. почты, то выводится ошибка
![image](https://github.com/savadevel/LogViewer/assets/69199994/a707c1c4-082c-4f8b-88f9-73cc6b1dc541)

5. Если не задан "Адрес получателя", то выводится ошибка
![image](https://github.com/savadevel/LogViewer/assets/69199994/5f34f1c5-3d0e-44a6-8030-df4f47ad33aa)

## Схема таблиц в БД
```sql
CREATE TABLE message (
  created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
  id VARCHAR NOT NULL,
  int_id CHAR(16) NOT NULL,
  str VARCHAR NOT NULL,
  status BOOL,
  address VARCHAR,
  COSTRAINT message_id_pk PRIMARY KEY(id)
);

CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);
CREATE INDEX log_address_idx ON log USING hash (address);

CREATE TABLE log (
  created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
  int_id CHAR(16) NOT NULL,
  str VARCHAR,
  address VARCHAR
);

CREATE INDEX log_address_idx ON log USING hash (address);
```

## Особенности работы

1. Программа запускается в docker't, при этом создаются три сервиса:
   * db - СУБД, используется PG
   * app - сервер приложений на perl
   * nginx - обратный прокси Nginx
  
2. Настройки приложения задаются в файле config.yml, в т.ч.
   * параметры подключения к СУБД (db_dsn, db_user, db_pass)
   * лимит строк (limit_rows)
   * путь к фалу с почтовым логом (file_log)

3. При запуске последовательно выполняются следующие шаги
   * удаление БД, если ранее создана (см. docker-compose.yml)
   * создание БД (см. docker-compose.yml)
   * запуск приложения (веб-приложения) 
   * создание подключения к СУБД
   * создание таблиц в БД
   * открытие файла
   * последовательная загрузка записей из почтового лога в БД (с авто commit)
   * ожидание подключений 
