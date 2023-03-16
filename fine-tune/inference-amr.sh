# bash inference-amr.sh "AMRBART-large-finetuned-AMR2.0-AMRParsing-v2"
export CUDA_VISIBLE_DEVICES=0
Data=UN_train_2

RootDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Dataset=data4parsing

BasePath=/mnt/nfs-storage                    # change dir here
DataPath=$RootDir/../../AMRMT/datasets/data4parsing/sliced_UN

ModelCate=AMRBART-large

MODEL=$RootDir/../../models/$1 
ModelCache=$BasePath/models
DataCache=$DataPath/.cache/dump-amrparsing

lr=1e-5

OutputDir=${DataPath}/outputs/${Data} 

if [ ! -d ${OutputDir} ];then
  mkdir -p ${OutputDir}
else
  echo $DataPath/ttm_test.jsonl
  read -p "${OutputDir} already exists, delete origin one [y/n]?" yn
  case $yn in
    [Yy]* ) rm -rf ${OutputDir}; mkdir -p ${OutputDir};;
    [Nn]* ) echo "exiting..."; exit;;
    * ) echo "Please answer yes or no.";;
  esac
fi

export HF_DATASETS_CACHE=$DataCache

if [ ! -d ${DataCache} ];then
  mkdir -p ${DataCache}
fi

# torchrun --nnodes=1 --nproc_per_node=1 --max_restarts=0 --rdzv_id=1 --rdzv_backend=c10d main.py \
python -u main.py \
    --data_dir $DataPath \
    --task "text2amr" \
    --test_file $DataPath/${Data}.jsonl \
    --output_dir $OutputDir \
    --cache_dir $ModelCache \
    --data_cache_dir $DataCache \
    --overwrite_cache True \
    --model_name_or_path $MODEL \
    --overwrite_output_dir \
    --unified_input True \
    --per_device_eval_batch_size 16 \
    --max_source_length 400 \
    --max_target_length 1024 \
    --val_max_target_length 1024 \
    --generation_max_length 1024 \
    --generation_num_beams 5 \
    --predict_with_generate \
    --smart_init False \
    --use_fast_tokenizer False \
    --logging_dir $OutputDir/logs \
    --seed 42 \
    --fp16 \
    --fp16_backend "auto" \
    --dataloader_num_workers 8 \
    --eval_dataloader_num_workers 2 \
    --include_inputs_for_metrics \
    --do_predict \
    --ddp_find_unused_parameters False \
    --report_to "tensorboard" \
    --dataloader_pin_memory True 2>&1 | tee $OutputDir/run.log
