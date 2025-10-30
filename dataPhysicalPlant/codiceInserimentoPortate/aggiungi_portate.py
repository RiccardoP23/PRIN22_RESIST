import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
import numpy as np
import os
import joblib
from sklearn.metrics import mean_squared_error, mean_absolute_error
from matplotlib import pyplot as plt
from openpyxl import Workbook
import warnings
from matplotlib.ticker import FuncFormatter, MaxNLocator
# Disabilitare tutti i warning
warnings.filterwarnings("ignore")

########################################################################
# Pulizia del terminale solo su Windows
if os.name == 'nt':
    os.system('cls')
else:
    os.system('clear')
########################################################################
# Costanti
g = 9.81  # Accelerazione di gravità in m/s^2
diameter_uscita = 0.05  # Diametro dell'uscita in metri (50 mm)
area_uscita = np.pi * (diameter_uscita / 2) ** 2  # Area dell'apertura di uscita in m^2
circumference_serbatoio = 250 / 100  # Circonferenza del serbatoio in metri (250 cm)
diameter_serbatoio = circumference_serbatoio / np.pi  # Diametro del serbatoio in metri
area_serbatoio = np.pi * (diameter_serbatoio / 2) ** 2  # Area della base del serbatoio in m^2
time_interval = 0.1  # Intervallo di acquisizione dei campioni in secondi
livello_zero = 209 / 1000  # Zero del livello a 209 mm, convertito in metri
########################################################################
filename_data='resultscenario_completiPortate.xlsx'
excel_sheets = pd.ExcelFile(filename_data).sheet_names
excel_sheets=['steadystate','fakeS5','fakeS6']
for sheet in excel_sheets:

	print(sheet)
	dataframe = pd.read_excel(filename_data, sheet_name=sheet)
	data_app=dataframe.copy()
	# if 'QwOUT' not in dataframe.columns:
	variables=['S2p','S6p','AV2p']
	data_tmp=dataframe[variables]
	# Conversione delle colonne: portata ingresso in m^3/s, livello in m, e percentuale di chiusura
	data_tmp['Portata_ingresso_m3_s'] = data_tmp['S2p'] / 3600  # m^3/h a m^3/s
	data_tmp['Livello_m'] = (data_tmp['S6p'] / 1000) - livello_zero  # Livello effettivo in metri
	data_tmp['Percentuale_chiusura'] = data_tmp['AV2p']   # Percentuale di chiusura in forma decimale

	# Imposta a zero il livello negativo (l'acqua non può scendere sotto 209 mm)
	data_tmp['Livello_m'] = data_tmp['Livello_m'].apply(lambda x: max(x, 0))

	# Calcolo della velocità di uscita (Torricelli)
	data_tmp['Velocità_uscita'] = np.sqrt(2 * g * data_tmp['Livello_m'])

	# Calcolo dell'area effettiva di uscita basata sulla percentuale di chiusura
	data_tmp['Area_effettiva_uscita'] = area_uscita * (1 - data_tmp['Percentuale_chiusura'])

	# Calcolo della portata di uscita (m^3/s) basata sulla chiusura
	data_tmp['Portata_uscita_m3_s'] = data_tmp['Area_effettiva_uscita'] * data_tmp['Velocità_uscita']

	# Calcolo della variazione del livello rispetto al campione precedente
	data_tmp['Delta_livello'] = data_tmp['Livello_m'].diff().fillna(0)

	# Calcolo della portata di uscita corretta in base alla variazione di livello
	data_tmp['Volume_variazione_m3'] = area_serbatoio * data_tmp['Delta_livello']
	data_tmp['Portata_uscita_m3_s'] = data_tmp['Portata_ingresso_m3_s'] - (data_tmp['Volume_variazione_m3'] / time_interval)

	# Assicuriamoci che la portata di uscita non sia negativa
	data_tmp['Portata_uscita_m3_s'] = data_tmp['Portata_uscita_m3_s'].apply(lambda x: max(x, 0))

	# Calcolo del volume d'acqua uscita in ogni intervallo (in m^3)
	data_tmp['Volume_uscita_m3'] = data_tmp['Portata_uscita_m3_s'] * time_interval

	# Calcolo cumulativo del volume totale d'acqua uscita
	data_tmp['Volume_totale_uscita_m3'] = data_tmp['Volume_uscita_m3'].cumsum()

	data_tmp['Portata_uscita_m3_h'] = data_tmp['Portata_uscita_m3_s'] * 3600
	dataframe['QwIN']=data_tmp['S2p']
	dataframe['QwOUT']=data_tmp['Portata_uscita_m3_h']
	dataframe['VwOUT']=data_tmp['Volume_totale_uscita_m3']
	
	with pd.ExcelWriter(filename_data, mode='a', engine='openpyxl', if_sheet_exists='replace') as writer:
		dataframe.to_excel(writer, index=False, sheet_name=sheet)
		
	
	