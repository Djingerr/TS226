function u = viterbi_decode(y, trellis)
% Decodage de Viterbi, treillis ferme. y : ns*L LLR (LLR > 0 <=> bit 0), u : K bits
ns = log2(trellis.numOutputSymbols);
S  = trellis.numStates;
L  = length(y) / ns;
K  = L - log2(S);
% Sorties BPSK (bit 0 -> +1, bit 1 -> -1) de chaque branche, ligne 2*etat + entree + 1
x = zeros(2*S, ns);
for etat = 0:S-1
    for entree = 0:1
        sortie = oct2dec(trellis.outputs(etat+1, entree+1));
        x(2*etat + entree + 1, :) = 1 - 2*(dec2bin(sortie, ns) - '0');
    end
end
metrique = -inf(S, L+1);
metrique(1, 1) = 0;                    % depart dans l'etat 0
etat_prec   = zeros(S, L);
entree_prec = zeros(S, L);
for l = 1:L
    y_l = y((l-1)*ns+1 : l*ns);
    for etat = 0:S-1
        for entree = 0:1
            % metrique de branche = correlation entre sortie BPSK et LLR recus
            candidat = metrique(etat+1, l) + x(2*etat + entree + 1, :) * y_l(:);
            suivant  = trellis.nextStates(etat+1, entree+1);
            if candidat > metrique(suivant+1, l+1)  % on ne garde que le meilleur chemin
                metrique(suivant+1, l+1)  = candidat;
                etat_prec(suivant+1, l)   = etat;
                entree_prec(suivant+1, l) = entree;
            end
        end
    end
end
% Traceback depuis l'etat 0 (treillis ferme)
u = zeros(L, 1);
etat = 0;
for l = L:-1:1
    u(l) = entree_prec(etat+1, l);
    etat = etat_prec(etat+1, l);
end
u = u(1:K);                            % on retire les m bits de fermeture
end
