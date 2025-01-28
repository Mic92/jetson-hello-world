import torch
breakpoint()
print(torch.cuda.is_available())
available_gpus = [torch.cuda.device(i) for i in range(torch.cuda.device_count())]
print(available_gpus)
