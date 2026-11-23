function c = cc_encode(u, trellis)
% Etat initial 0, treillis ferme : c contient ns*L bits, avec L = K + m
K  = length(u);
ns = log2(trellis.numOutputSymbols);
m  = log2(trellis.numStates);
L  = K + m;
c    = zeros(ns*L, 1);
etat = 0;
for l = 1:L
    if l <= K
        entree = u(l);
    else
        % Fermeture : on choisit l'entree qui met un 0 dans le poids fort de l'etat suivant
        entree = double(trellis.nextStates(etat+1, 1) >= 2^(m-1));
    end
    sortie = oct2dec(trellis.outputs(etat+1, entree+1)); % outputs est en octal
    c((l-1)*ns+1 : l*ns) = dec2bin(sortie, ns) - '0';
    etat = trellis.nextStates(etat+1, entree+1);
end
end
