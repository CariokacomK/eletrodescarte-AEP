package br.com.eletrodescarte.utils;

import br.com.eletrodescarte.models.PontoColeta;
import java.util.List;

/**
 * Utilitário de ordenação em memória utilizando o algoritmo QuickSort.
 * Atende ao requisito de ordenação explícita na memória da aplicação (sem depender do banco).
 * 
 * Análise de Complexidade de Tempo (Notation Big-O):
 * - Melhor Caso: O(n log n) - Ocorre quando o pivô divide a lista em partes aproximadamente iguais.
 * - Caso Médio: O(n log n) - Desempenho esperado para a maioria das listas desordenadas.
 * - Pior Caso: O(n^2) - Ocorre se o pivô escolhido for sempre o menor ou maior elemento (ex: lista já ordenada).
 * 
 * Análise de Complexidade de Espaço:
 * - Complexidade de Espaço: O(log n) - Espaço de memória adicional devido à pilha de recursão.
 */
public class QuickSortUtil {

    public static void sort(List<PontoColeta> pontos) {
        if (pontos == null || pontos.size() <= 1) {
            return;
        }
        quickSort(pontos, 0, pontos.size() - 1);
    }

    private static void quickSort(List<PontoColeta> list, int low, int high) {
        if (low < high) {
            int pi = partition(list, low, high);
            quickSort(list, low, pi - 1);
            quickSort(list, pi + 1, high);
        }
    }

    private static int partition(List<PontoColeta> list, int low, int high) {
        // Usando o elemento da extremidade direita como pivô
        PontoColeta pivot = list.get(high);
        int i = (low - 1);

        for (int j = low; j < high; j++) {
            // Comparando em ordem alfabética (case-insensitive) pelo nome do Ponto de Coleta
            if (list.get(j).getNome().compareToIgnoreCase(pivot.getNome()) <= 0) {
                i++;
                swap(list, i, j);
            }
        }
        swap(list, i + 1, high);
        return i + 1;
    }

    private static void swap(List<PontoColeta> list, int i, int j) {
        PontoColeta temp = list.get(i);
        list.set(i, list.get(j));
        list.set(j, temp);
    }
}
