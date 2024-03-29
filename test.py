reader = open('model_290324_CP_ber_evm\\message.txt', 'r')
data1 = reader.read().split('\n')
reader = open('model_290324_CP_ber_evm\\decoded_message.txt', 'r')
data2 = reader.read().split('\n')
reader.close()
message = []
decoded_message = []

for i in range(len(data1)):
    message.append([int(k) for k in [*data1[i]]])
    decoded_message.append([int(k) for k in [*data2[i]]])

total = len(decoded_message)*len(decoded_message[0])

sum_er = 0
for i in range(64):
    for j in range(4):
        sum_er += abs(message[i][j]-decoded_message[i][j])

print(sum_er/total)