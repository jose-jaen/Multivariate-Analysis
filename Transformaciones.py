# Librerías necesarias
import math
import numpy as np
import pandas as pd
import warnings
from scipy.stats import skew
warnings.filterwarnings('ignore')

# Leemos los datos
datos = pd.read_csv('coches.csv')

# Breve exploración
print('Hay un total de', np.shape(datos)[0], \
      'observaciones con', np.shape(datos)[1], \
      'variables en nuestro conjunto de datos')

# Tipos de variables
variables = datos.columns
bina, multi = 0, 0
for i in variables:
    if len(datos[i].unique()) == 2:
        bina += 1
    elif len(datos[i].unique()) > 2 and len(datos[i].unique()) <= 4:
        multi += 1

print('Concretamente, encontramos', bina, 'variables binarias,',
      multi, 'variable multiestado, y las', np.shape(datos)[1] - bina - multi,
      'restantes son cuantitativas')

# Transformaciones para simetrizar las distribuciones
cuantis = []
for i in variables:
    if len(datos[i].unique()) > 4:
        cuantis.append(i)

normal, sqrt, log = [], [], []
for i in cuantis:
    normal.append(skew(datos[i]))
    log.append(skew(np.log(datos[i])))
    sqrt.append(skew(np.sqrt(datos[i])))

# Guardo transformaciones en un pandas dataframe
comparar = pd.DataFrame({'normal': normal, 'log': log, 'sqrt': sqrt})

# Identificamos la transformación que devuelve mayor simetría
filas, col = [], []
for i in range(len(comparar)):
    for j in comparar.columns:
        if abs(comparar)[j][i] == min(abs(comparar).loc[i]):
            filas.append(i)
            col.append(j)

final = pd.DataFrame({'fila':filas, 'transf':col})

# Aplicamos las transformaciones a nuestro conjunto de datos
for i in range(len(final)):
    if final['transf'][i] == 'sqrt':
        datos[cuantis[i]] = np.sqrt(datos[cuantis[i]])
    elif final['transf'][i] == 'log':
        datos[cuantis[i]] = np.log(datos[cuantis[i]])
