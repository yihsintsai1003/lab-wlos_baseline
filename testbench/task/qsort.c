#include "qsort.h"

int __attribute__ ( ( section ( ".mprjram" ) ) ) partition(int low,int hi){
	int pivot = qsA[hi];
	int i = low-1,j;
	int temp;
	for(j = low;j<hi;j++){
		if(qsA[j] < pivot){
			i = i+1;
			temp = qsA[i];
			qsA[i] = qsA[j];
			qsA[j] = temp;
		}
	}
	if(qsA[hi] < qsA[i+1]){
		temp = qsA[i+1];
		qsA[i+1] = qsA[hi];
		qsA[hi] = temp;
	}
	return i+1;
}

void __attribute__ ( ( section ( ".mprjram" ) ) ) sort(int low, int hi){
	if(low < hi){
		int p = partition(low, hi);
		sort(low,p-1);
		sort(p+1,hi);
	}
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) qsort(){
	sort(0,SIZE-1);
	return qsA;
}
