
using Plots
include("../src/ExpEval.jl")



ID = 3
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);


M1 = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")



n, m = size(TRAIN)

### INTRODUCCION DE NaNs (REVISAR)
### ESCRIBIR COMO FUNCION APARTE: REPLICAR LO DE ARAS, PROPONER OTRAS

for i = 1:n
    I1_miss_mean = .5
    I1_length = round(Int, I1_miss_mean * rand() * n)
    I1_start = rand(1:n - I1_length + 1)
    
    TRAIN[i, I1_start:I1_start+I1_length] .= NaN
end

for i = 1:n
    I2_miss_mean = .2
    I2_length = round(Int, I2_miss_mean * rand() * n)
    I2_start = rand(1:n - I2_length + 1)
    
    TRAIN[i, I2_start:I2_start+I2_length] .= NaN
end

### DEFINIRI CONVENCION PARA GUARDADO DE FIGURAS Y RESULTADOS EN out/
### AGREGAR ETIQUETAS INFORMATIVAS EN LAS FIGURAS DE TRABAJO

fig = plot()
figname = "fig.svg"


M2 = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 0)
ExpEval.scatter_dist_matrices!(M1, M2, save_as="out/$figname", label="γ=0")


M2 = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 1)
ExpEval.scatter_dist_matrices!(M1, M2, save_as="out/$figname", label="γ=1")

M2 = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 2)
ExpEval.scatter_dist_matrices!(M1, M2, save_as="out/$figname", label="γ=2")