import telebot
import random
from telebot import types, TeleBot

token = "2097729556:AAE8A0ZxzRSoNxZ2DajeRvpnc5g23I-_NHM"

bot: TeleBot = telebot.TeleBot(token)

RANDOM_TASKS = ['Написать Гвидо письмо', 'Выучить Python', 'Записаться на курс в Нетологию', 'Посмотреть 4 сезон Рик и Морти']


HELP = """
/help - вывести список доступных команд.
/add - добавить задачу в список (название задачи запрашиваем у пользователя)
/show - напечатать все добавленные задачи
/random - дбавить случайную задачу на дату Сегодня"""

tasks = {}

def add_todo(date, task):
    if date in tasks:
        # Дата есть в словаре
        tasks[date].append(task)
    else:
        # Даты в словаре нет
        # Создаем записб с ключем date
        tasks[date] = []
        tasks[date].append(task)

@bot.message_handler(commands=["help"])
def help(message):
    bot.send_message(message.chat.id, HELP)



@bot.message_handler(commands=["add", "todo"])
def add(message):
    bot.send_message(message.chat.id, "На какую дату добавить задачу?")
    bot.register_next_step_handler(message, get_date)

def get_date(message): #получаем дату
    global date
    date = message.text.lower()
    bot.send_message(message.from_user.id, "Хорошо. Что за задачу надо добавить на " + date + "?")
    bot.register_next_step_handler(message, get_task)

def get_task(message):
    global task
    task = message.text
    # bot.send_message("Задача " + task + " добавлена на дату " + date)

    # bot.send_message(message.chat.id, "Хорошо. Что за задачу надо добавить на " + date + "?")
    # bot.register_next_step_handler(message, task)
    # command = message.text.split(maxsplit=2)
    # bot.send_message(message.chat.id, command)
    # date = command[1].lower()
    # task = command[2]
    add_todo(date, task)
    text = "Задача " + task + " добавлена на дату " + date
    bot.send_message(message.chat.id, text)

@bot.message_handler(commands=["random"])
def random_add(message):
    date = "сегодня"
    task = random.choice(RANDOM_TASKS)
    add_todo(date, task)
    text = "Задача " + task + " добавлена на дату " + date
    bot.send_message(message.chat.id, text)

@bot.message_handler(commands=["show", "print"])
def show(message): #message.text = /print <date>
    bot.send_message(message.chat.id, "На какую дату показать задачи?")
    bot.register_next_step_handler(message, get_date_show)

def get_date_show(message): #получаем дату
    global date
    date = message.text.lower()
    text = ""
    if date in tasks:
        text = date.upper() + "\n"
        for task in tasks[date]:
            text = text + "[] " + task + "\n"
    else:
        text = "Задач на эту дату нет. Отдыхаем."
        bot.send_message(message.chat.id, text)
    bot.send_message(message.chat.id, HELP)

    # command = message.text.split(maxsplit=1)
    # date = command[1].lower()
    # text = ""
    # if date in tasks:
    #     text = date.upper() + "\n"
    #     for task in tasks[date]:
    #         text = text + "[] " + task + "\n"
    # else:
    #     text = "Задач на эту дату нет"
    # bot.send_message(message.chat.id, text)

@bot.message_handler(content_types=['animation', 'audio', 'contact', 'dice', 'document', 'location', 'photo', 'poll', 'sticker', 'text', 'venue', 'video', 'video_note', 'voice'])
def err(message):
    text = message.text
    bot.send_message(message.chat.id, "Команда " + text + " не распознана. Попробуйте еще. Выберите из списка доступных команд.")
    # bot.send_message(message.chat.id, HELP)
    markup = types.InlineKeyboardMarkup(row_width=2)
    item1 = types.InlineKeyboardButton("Добавить задачу", callback_data='add')
    item2 = types.InlineKeyboardButton("Помощь", callback_data='help')
    item3 = types.InlineKeyboardButton("Рандомная задача", callback_data='random')
    item4 = types.InlineKeyboardButton("Показать задачи", callback_data='show')
    markup.add(item1, item2, item3, item4)
    bot.send_message(message.chat.id, 'Вот список доступных команд', reply_markup=markup)

    # markup = types.ReplyKeyboardMarkup(resize_keyboard=True, row_width=2)
    # item1 = types.KeyboardButton("/add")
    # item2 = types.KeyboardButton("/help")
    # item3 = types.KeyboardButton("/random")
    # item4 = types.KeyboardButton("/show")
    # markup.add(item2, item1, item3, item4)
    # bot.send_message(message.chat.id, "Выберите действие", reply_markup=markup)

@bot.callback_query_handler(func=lambda call: True)
def callback_inline(call, callback=None):
    try:
        if call.message:
            if call.data =='add':
                # bot.send_message(call.message.chat.id, '/add')
                # bot.message_handler(commands="add")
                # msg = bot.send_message(call.message.chat.id, 'ok')
                # bot.register_next_step_handler(msg, callback=add)
                # bot.register_next_step_handler('/add')
                bot.message_handler(commands="/add")
            elif call.data =='help':
                bot.send_message(call.message.chat.id, '/help')
    except Exception as e:
        print(repr(e))

# Постоянно обращается к серверам телеграмм
bot.polling(none_stop=True)
# bot.infinity_polling()
