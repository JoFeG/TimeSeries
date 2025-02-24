
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
    I1_miss_mean = .05
    I1_length = round(Int, I1_miss_mean * rand() * m)
    I1_start = rand(1:m - I1_length + 1)
    
    TRAIN[i, I1_start:I1_start+I1_length] .= NaN
end

for i = 1:n
    I2_miss_mean = .01
    I2_length = round(Int, I2_miss_mean * rand() * m)
    I2_start = rand(1:m - I2_length + 1)
    
    TRAIN[i, I2_start:I2_start+I2_length] .= NaN
end

### DEFINIRI CONVENCION PARA GUARDADO DE FIGURAS Y RESULTADOS EN out/
### AGREGAR ETIQUETAS INFORMATIVAS EN LAS FIGURAS DE TRABAJO

#=
fig = plot()
figname = "DTWA_test_fig.pdf"

M2 = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 0)
ExpEval.scatter_dist_matrices!(M1, M2, save_as="figs/$figname", label="γ=0")

MA = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 1)
ExpEval.scatter_dist_matrices!(M1, MA, save_as="figs/$figname", label="A correction factor")

MB = ExpEval.calculate_distance_matrix_dtwA(TRAIN, 2)
ExpEval.scatter_dist_matrices!(M1, MB, save_as="figs/$figname", label="B correction factor")
=#

fig = plot() 
ExpEval.scatter_dist_matrices!(M1, MA, save_as="figs/DTWA_test_fig.pdf", label="A correction factor")

fig = plot() 
ExpEval.scatter_dist_matrices!(M1, MB, save_as="figs/DTWB_test_fig.pdf", label="B correction factor")