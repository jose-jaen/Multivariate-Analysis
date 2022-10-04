datos = readtable('coches.csv');
cuantis = table2array(datos(:, [3:11]));

% Gráfico de dispersión matricial

plotmatrix(cuantis)

% Análisis multivariante exploratorio

mean(cuantis)
S = cov(cuantis, 1)
R = corr(cuantis)
var_gen = det(S)
var_total = trace(S)
eta_square = 1 - det(R)

% Los nuevos datos son las variables transformadas en Python

datos = readtable('coches_new.csv');
cuantis = table2array(datos(:, [3:11]));

% Gráfico de dispersión matricial en las nuevas variables

plotmatrix(cuantis)

% Análisis multivariante exploratorio en las nuevas variables

mean(cuantis)
S = cov(cuantis, 1)
R = corr(cuantis, 1)
var_gen = det(S)
var_total = det(S)
eta_square = 1 - det(R)

% Análisis Variable Binaria

combustible = table2array([datos(:, [1])]);
gplotmatrix(cuantis, [], combustible, 'br')

gasolina_posicion = find(combustible == 1);
diesel_posicion = find(combustible == 0);
p = 9; n_gasolina = 181; n_diesel = 20;
gasolina = [cuantis(gasolina_posicion',:)];
diesel = [cuantis(diesel_posicion',:)];

% Preparamos contraste de hipótesis T^2 de Hotelling

[m_gas, S_gas, R_gas] = stats(gasolina); [m_diesel, S_diesel, R_diesel] = stats(diesel);
Sp = ((1/(n_gasolina + n_diesel))*(n_gasolina*S_gas + n_diesel*S_diesel));
diferencia = m_gas'-m_diesel';
f = (n_gasolina+n_diesel-p-1)/(p*(n_gasolina + n_diesel-2))*(n_gasolina*n_diesel)/(n_gasolina + n_diesel)*diferencia'*inv(Sp)*diferencia;
df1 = p; df2 = n_gasolina + n_diesel - p - 1;
cv = finv(0.95, df1, df2);

% Análisis Variable Multiestado

motriz = table2array(datos(:, 2));
gplotmatrix(cuantis,[], motriz)
tras = find(motriz == 1); del = find(motriz == 2); cuatro = find(motriz == 3);
tras = [cuantis((tras)',:)]; del = [cuantis((del)',:)]; cuatro = [cuantis((cuatro)',:)];

% Preparamos contraste de hipótesis Lambda de Wilks

[m_tras, S_tras, R_tras] = stats(tras);
[m_del, S_del, R_del] = stats(del);
[m_cuatro, S_cuatro, R_cuatro] = stats(cuatro);
n_tras = 75; n_del = 118; n_cuatro = 8;
dif_tras = m_tras' - mean(cuantis)'; dif_del = m_del' - mean(cuantis)'; dif_cuatro = m_cuatro' - mean(cuantis)';
B_tras = n_tras*dif_tras*dif_tras'; B_del = n_del*dif_del*dif_del'; B_cuatro = n_cuatro*dif_cuatro*dif_cuatro';
B = B_tras + B_del + B_cuatro;
W_tras = n_tras*S_tras; W_del = n_del*S_del; W_cuatro = n_cuatro*S_cuatro;
W = W_tras + W_del + W_cuatro;
Disp_total = B + W;
est = (det(W)/(det(W + B)));
a = 201 - 3; b = 3-1 ; p = 9;
alpha = a + b-(p + b + 1)/2; beta = sqrt(((p^2)*(b^2) - 4)/((p^2) + (b^2) - 5));
lambda = (p*b-2)/4;
f = ((1-(est^(1/beta)))/((est^(1/beta))))*(((alpha*beta) - 2*lambda)/(p*b));
df1 = p*b; df2 = alpha*beta - 2*lambda;
cv = finv(0.95, df1, df2)

% Cargamos la base de datos para reduccion de la dimensionalidad

>> datos = readtable('coches.csv');

% Observamos la estructura de los datos

>> datos(1:10, :)

% Seleccionamos las variables cuantitativas

>> X_cuant = table2array(datos(:, 3:11));
>> X_cuant(:, 5) = X_cuant(:, 5)*0.45359237;
>> X_cuant(:, 8) = X_cuant(:, 8)/10;
>> X_cuant(:, 9) = X_cuant(:, 9)/100;

% Calculamos indice escalar de correlacion

>> format long
>> 1 - det(corr(X_cuant)) % eta^2

% Estudiamos diferencias entre varianzas

>> var(X_cuant, 1)

% Realizamos PCA 

>> [T1,Y1,acum1,T2,Y2,acum2] = PCA(X_cuant);

% Elegimos tres Componentes Principales

>> T2(:, 1:3)

% Grafico 3D

>> [coeff,score,latent,tsquared,explained] = pca(X_cuant, 'VariableWeights','variance');
>> scatter3(score(:, 1),score(:, 2),score(:, 3))
axis equal
xlabel('1a  Componente Principal')
ylabel('2a  Componente Principal')
zlabel('3a  Componente Principal')

% Vemos correlaciones con variables originales
>> corr(Y2(:, 1), X_cuant)'                            
>> corr(Y2(:, 2), X_cuant)'                             
>> corr(Y2(:, 3), X_cuant)'   

% Aunamos variables cualitativas                  

>> X_cual = table2array(datos(:, 1:2));

% Matriz de datos conjunta

>> X = [X_cuant X_cual];

% Calculamos distancias estadisticas

>> M = squareform(pdist(X_cuant, 'mahal'));
>> M = M.*M;
>> M = M/vgeom(M);
>> [n, p] = size(X);
>> X3 = X_cual;
>>  for i=1:n
    for j=i:n
        alpha(i,j)=sum(X3(i,:)==X3(j,:));
        alpha(j,i)=alpha(i,j);
    end
 end
>> S_cual = alpha./p;
>> D_cual = 2*(ones(size(S_cual)) - S_cual);
>> D_cual = D_cual/vgeom(D_cual);
>> D = M + D_cual;

% Realizamos MDS

>> [Y,vaps,percent,acum] = coorp(D);

% Correlaciones con variables originales

>> corr_table = correlacions(X, Y, 9, 2);

% Identificacion de perfiles

>> identif_cuantis(X_cuant, Y)
>> identif_cualis(X_bin, Y)

% Correccion de correlaciones por juntar binaria y multiestado

>> corr_table = correlacions(X, Y, 9, 2);
>> corr(Y(:,1:3),X(:,11),'type','Spearman')'      

% Cargamos los datos

>> datos = readtable('coches.csv');
>> X_org = table2array(datos);

% Observamos la distribucion de las variables y sus relaciones lineales

>> plotmatrix(X_org(:,3:11))

% Aplicamos las transformaciones necesarias para aumentar la simetria

>> X = [X_org(:,1:2), log(X_org(:,3:4)), log(X_org(:,5)*0.45359237), sqrt(X_org(:,6)), log(X_org(:,7:11))];

% Vemos el efecto final

>> figure
>> plotmatrix(X(:,3:11))

% Identificamos los tipos de variables

X_cuant = X(:,3:11);
X_cual = X(:,1:2);

% Calculamos las distancias e imponemos igual variabilidad geometrica

>> M = squareform(pdist(X_cuant, 'mahal'));
>> M = M.*M;
>> M = M/vgeom(M);
>> [n, p] = size(X);
>> X3 = X_cual;

>>  for i=1:n
    for j=i:n
        alpha(i,j)=sum(X3(i,:)==X3(j,:));
        alpha(j,i)=alpha(i,j);
    end
 end

>> S_cual = alpha./p;
>> D_cual = 2*(ones(size(S_cual)) - S_cual);
>> D_cual = D_cual/vgeom(D_cual);
>> D = M + D_cual;

% Solo necesitamos el triangulo superior de la matriz de distancias

[n,p] = size(D);
for i = 1:n
    D(i,i) = 0;
end;

% Clasificación Jerárquica

>> Y = squareform(D);
>> Z_min = linkage(Y, 'single');
>> Z_max = linkage(Y, 'complete');
>> Z_UPGMA = linkage(Y, 'average');

% Visualizamos los resultados 

>> figure
>> subplot(1, 3, 1)
>> dendrogram(Z_min)
>> title('Método del Mínimo')
>> subplot(1, 3, 2)
>> dendrogram(Z_max)
>> title('Método del Máximo')
>> subplot(1, 3, 3)
>> dendrogram(Z_UPGMA)
>> title('Método UPGMA')

% Vector con correlaciones cofenéticas 

cofenetica = [cophenet(Z_min, Y); cophenet(Z_max, Y); cophenet(Z_UPGMA, Y)];

% Vemos cuál perturba más

for i = 1:size(cofenetica,1)
  if min(cofenetica)==cofenetica(i)
  disp(i)
  end;
end;

% Método que perturba menos (óptimo)

for i = 1:size(cofenetica,1)
  if max(cofenetica)==cofenetica(i)
  disp(i)
  end;
end;
figure

% Visualizamos UPGMA con nuestro threshold

dendrogram(Z_UPGMA,0,'colorthreshold',2.5)

% Tendencias y patrones con los grupos

for j = 0:1
  for i = 1:size(X,1)
    if X(i,1) == j
      disp(i)
    end;
  end;
end;

for j = 1:3
  for i = 1:size(X,2)
    if X(i,1) == j
      disp(i)
    end;
  end;
end;

% Representacion MDS

[Y,vaps,percent,acum] = coorp(D)

% Aplicamos k-means ()

[C,s,IDX]=kmedias2(Y, 6)

% Vemos interpretación de las coordenadas principales

>> correlaciones2(X, Y, 9, 1)

% Diferencias entre grupos del k-means 

>> medias=splitapply(@mean,X_cuant,IDX)
>> medianas=splitapply(@median,X_cuant,IDX)
>> mode=splitapply(@mode,X_cual,IDX)