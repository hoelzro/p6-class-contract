use v6;

class ContractClassHOW is Metamodel::ClassHOW {
    method add_method(Mu $obj, $name, $code) {
        if $name ne 'PRE' && $name ne 'POST' {
            $code.wrap(-> \SELF, | {
                do { # workaround for RT #125154
                    PRE  { SELF.can('PRE')  ?? SELF.PRE()  !! True }
                    POST { SELF.can('POST') ?? SELF.POST() !! True }

                    callsame
                }
            });
        }

        return callsame;
    }
}

my package EXPORTHOW {}
EXPORTHOW::<class> = ContractClassHOW;
