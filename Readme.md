# vllm-vega

vllm on MI50/MI60 multiple GPU server

Inspired by 
- https://github.com/Said-Akbar/triton-gcn5
- https://github.com/Said-Akbar/vllm-rocm
- https://github.com/lamikr/rocm_sdk_builder


## setup
```sh
podman build -t vllm_vega:0.7.3 .
podman run -it --device=/dev/kfd --device=/dev/dri -v /opt/models:/opt/models -p 8888:8888  vllm_vega:0.7.3 vllm serve /opt/models/DeepSeek-R1-Distill-Qwen-32B-Japanese-Q5_K_M.gguf  --tensor-parallel-size 2 --host 0.0.0.0  --port 8888  --max_model_len 1024
```
